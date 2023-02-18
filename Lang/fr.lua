-- parse FR from CombatAnalysis
Global.ParseFr = function(line)
    -- 1) Damage line ---

    local initiatorName, avoidAndCrit, skillName, targetName, amount, dmgType, moralePower = string.match(line,
        "^(.*) a infligé un coup (.*)avec (.*) sur (.*) pour ([%d,]*) points de type (.*) à l'entité ?(.*)%.$"); -- (updated in v4.1.0)

    if (initiatorName ~= nil) then
        local avoidType =
            string.match(avoidAndCrit, "partiellement bloqué") and 8 or
            string.match(avoidAndCrit, "partiellement paré") and 9 or
            string.match(avoidAndCrit, "partiellement esquivé ") and 10 or
            1;
        local critType =
            string.match(avoidAndCrit, "critique") and 2 or
            string.match(avoidAndCrit, "dévastateur") and 3 or 1;

        -- skillName = string.match(skillName,"^ avec (.*)$") or L.DirectDamage; -- (as of v4.1.0)
        skillName = ""
        -- damage was absorbed
        if targetName == nil then
            targetName = string.gsub(targetNameAmountAndType, "^[Tt]he ", "");
            amount = 0;
            dmgType = 12;
            moralePower = 3;
            -- some damage was dealt
        else
            amount = string.gsub(amount, ",", "") + 0;

            ---			dmgType = string.match(dmgType, "^%(.*%) (.*)$") or dmgType; -- 4.2.3 adjust for mounted combat
            -- note there may be no damage type
            dmgType =
                dmgType == "Commun" and 1 or
                dmgType == "Feu" and 2 or
                dmgType == "Foudre" and 3 or
                dmgType == "Froid" and 4 or
                dmgType == "Acide" and 5 or
                dmgType == "Ombre" and 6 or
                dmgType == "Lumière" and 7 or
                dmgType == "Beleriand" and 8 or
                dmgType == "Ouistrenesse" and 9 or
                dmgType == "de nain d'antan" and 10 or
                dmgType == "Orc" and 11 or
                dmgType == "Fell-wrought" and 12 or 13;
            moralePower = (moralePower == "Morale" and 1 or moralePower == "Puissance" and 2 or 3);
        end

        -- Currently ignores damage to power
        if (moralePower == 2) then return nil end

        -- Update
        return 1, trim_articles(initiatorName), trim_articles(targetName), skillName, amount, avoidType, critType,
            dmgType;
    end

    -- 2) Heal line --
    --     (note the distinction with which self heals are now handled)
    --     (note we consider the case of heals of zero magnitude, even though they presumably never occur)

    --	[slfHeal] Arc du Juste a appliqué un soin critique à Ardichas, redonnant 52 points à l'entité Puissance.
    --  [slfHeal] Esprit de soliloque a appliqué un soin critique à Yogimen, redonnant 228 points à l'entité Moral.
    --  [Heal]    Eleria a appliqué un soin avec Paroles de guérison Ardicapde, redonnant 227 points à Moral.
    initiator_name, match = string.match(line, '^(.*) a appliqu\195\169 un soin (.*)%.$');

    if (initiator_name ~= nil) then
        crit_type =
            string.match(match, 'critique') and 2 or
            string.match(match, 'dévastateur') and 3 or
            1;
        match = string.gsub(match, '^critique ', '');
        match = string.gsub(match, '^dévastateur ', '');

        local self_heal = (string.match(match, '^\195\160 ') and true or false);

        -- Soins personnels (Self heal)
        if (self_heal) then
            skill_name = initiator_name;
            target_name, dmg_amount, morale_power = string.match(match,
                '^\195\160 (.*), redonnant ([%d,]*) points? \195\160 l\'entit\195\169 ?(.*)$');
            initiator_name = target_name;

            -- Soins sur une cible (Heal applied)
        else
            skill_name, target_name, dmg_amount, morale_power = string.match(match,
                '^avec (.*) ([^%s]+), redonnant ([%d,]*) points? \195\160 ?(.*)$');
        end

        morale_power = (morale_power == 'Moral' and 1 or (morale_power == 'Puissance' and 2 or 3));
        dmg_amount = (morale_power == 3 and 0 or string.gsub(dmg_amount, ',', '') + 0);

        return (morale_power == 2 and 4 or 3), trim_articles(initiator_name), trim_articles(target_name), skill_name,
            dmg_amount, crit_type;
    end
    -- 4) Avoid line --
    -- L' Profanateur ghâshfra vigoureux a essayé d'utiliser une attaque de lancer faible sur MarieChantal mais a esquivé la tentative.
    -- L' Berserker hante-jours a essayé d'utiliser une double attaque au corps à corps sur Eleria mais elle a paré la tentative.
    -- L' Archer corsaire a essayé d'utiliser une attaque au corps à corps faible sur Cashel mais il a paré la tentative.
    -- Ardichas a essayé d'utiliser Tir pénétrant amélioré : Brûlure sur le Trompeur immonde vigoureux mais il a esquivé la tentative.

    -- 4a) Évitements complets (Full avoids)
    local initiator_name, skill_name, target_name, avoidType = string.match(line,
        "^(.*) a essayé d'utiliser (.*) sur (.*) mais (.*) la tentative%.$");

    if (initiator_name ~= nil) then
        avoid_Type =
            string.match(avoidType, "bloqué") and 5 or
            string.match(avoidType, "paré") and 6 or
            string.match(avoidType, "esquivé") and 7 or
            string.match(avoidType, "résisté") and 4 or
            string.match(avoidType, "immunisé contre") and 3 or 1;

        if (avoid_type == 1) then
            return nil;
        end
        return 1, trim_articles(initiator_name), trim_articles(target_name), skill_name, 0, avoid_Type, 1, 10;
    end

    -- 4b) miss or deflect (deflect added in v4.2.2)
    -- La Berserker hante-jours n'a pas réussi à utiliser une frappe de taille faible sur la Eleria.
    local initiator_name, skill_name, target_name = string.match(line, "^(.*) n'a pas réussi à utiliser (.*) sur (.*)%.$");

    if (initiator_name ~= nil) then
        avoid_type = 2;

        return 1, trim_articles(initiator_name), trim_articles(target_name), skill_name, 0, avoid_type, 1, 10;
    end

    -- 5) Reflect line --
    -- Norchador a renvoyé 210 Ombre de dégâts au Moral de la Eleria.
    -- Le Sangsue gardienne a renvoyé 339 points redonnés au Moral de Eleria.
    local initiatorName, amount, dmgType, targetName = string.match(line,
        "^(.*) a renvoyé ([%d,]*) (.*) au Moral de (.*)%.$");

    if (initiatorName ~= nil) then
        local skillName = "Reflect";
        amount = string.gsub(amount, ",", "") + 0;

        local dmgType = string.match(dmgType, "^(.*)de dégâts$");
        -- a damage reflect
        if (dmgType ~= nil) then
            dmgType =
                dmgType == "Commun" and 1 or
                dmgType == "Feu" and 2 or
                dmgType == "Foudre" and 3 or
                dmgType == "Froid" and 4 or
                dmgType == "Acide" and 5 or
                dmgType == "Ombre" and 6 or
                dmgType == "Lumière" and 7 or
                dmgType == "Beleriand" and 8 or
                dmgType == "Ouistrenesse" and 9 or
                dmgType == "Nain d'antan" and 10 or 11;

            -- Update
            return 1, trim_articles(initiatorName), trim_articles(targetName), skillName, amount, 1, 1, dmgType;
            -- a heal reflect
        else
            -- Update
            return 3, trim_articles(initiatorName), trim_articles(targetName), skillName, amount, 1;
        end
    end
end
