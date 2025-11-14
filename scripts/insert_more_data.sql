-- Script d'insertion de données supplémentaires pour CropGuardian
-- Tables: insects et traitements

-- ============================================
-- INSECTES SUPPLÉMENTAIRES
-- ============================================

-- 1. Puceron vert du pêcher (Myzus persicae)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Puceron vert du pêcher',
  'Myzus persicae',
  'Petit insecte vert de 1-2mm, corps mou, se nourrit de la sève des plantes. Très polyphage, attaque plus de 400 espèces végétales.',
  'https://images.unsplash.com/photo-1589820296156-2454bb8a6ad1',
  'Hemiptera',
  'Cultures maraîchères, arbres fruitiers, plantes ornementales',
  'Affaiblissement de la plante, déformation des feuilles, transmission de virus',
  ARRAY['Feuilles enroulées', 'Miellat collant', 'Présence de fourmis', 'Jaunissement']
);

-- 2. Doryphore de la pomme de terre (Leptinotarsa decemlineata)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Doryphore',
  'Leptinotarsa decemlineata',
  'Coléoptère de 10-12mm, rayé jaune et noir. Larves rouge-orangé. Ravageur majeur des pommes de terre et aubergines.',
  'https://images.unsplash.com/photo-1563089145-599997674d42',
  'Coleoptera',
  'Cultures de solanacées (pomme de terre, aubergine, tomate)',
  'Défoliation complète, perte de rendement importante',
  ARRAY['Feuilles dévorées', 'Larves oranges visibles', 'Squelettisation des feuilles']
);

-- 3. Chenille légionnaire d''automne (Spodoptera frugiperda)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Chenille légionnaire d''automne',
  'Spodoptera frugiperda',
  'Chenille de 3-4cm, brun-gris avec bandes longitudinales. Ravageur très destructeur du maïs et autres céréales.',
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
  'Lepidoptera',
  'Maïs, riz, sorgho, coton, légumineuses',
  'Destruction massive des cultures, pertes économiques importantes',
  ARRAY['Trous dans les feuilles', 'Excréments visibles', 'Épis endommagés', 'Croissance ralentie']
);

-- 4. Mouche blanche (Bemisia tabaci)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Mouche blanche',
  'Bemisia tabaci',
  'Petit insecte blanc de 1-2mm, ailes poudreuses. Vecteur de nombreux virus. Se reproduit très rapidement.',
  'https://images.unsplash.com/photo-1530587191325-3db32d826c18',
  'Hemiptera',
  'Cultures sous serre, tomates, cucurbitacées, coton',
  'Affaiblissement, transmission de virus, fumagine',
  ARRAY['Nuage blanc au toucher', 'Miellat', 'Feuilles jaunies', 'Fumagine noire']
);

-- 5. Thrips (Frankliniella occidentalis)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Thrips des fleurs',
  'Frankliniella occidentalis',
  'Minuscule insecte de 1mm, jaune-brun. Pique les cellules végétales. Vecteur de virus (TSWV).',
  'https://images.unsplash.com/photo-1563089145-599997674d42',
  'Thysanoptera',
  'Cultures florales, légumes, fruits',
  'Décoloration argentée, déformation des fleurs et fruits',
  ARRAY['Taches argentées', 'Déformation des feuilles', 'Fleurs déformées', 'Présence d''insectes minuscules']
);

-- 6. Cochenille farineuse (Planococcus citri)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Cochenille farineuse',
  'Planococcus citri',
  'Insecte de 3-5mm couvert de cire blanche. Forme des amas cotonneux. Suce la sève.',
  'https://images.unsplash.com/photo-1589820296156-2454bb8a6ad1',
  'Hemiptera',
  'Agrumes, plantes ornementales, vignes',
  'Affaiblissement, miellat, fumagine, transmission de virus',
  ARRAY['Amas blancs cotonneux', 'Miellat collant', 'Feuilles jaunies', 'Fumagine']
);

-- 7. Noctuelle de la tomate (Helicoverpa armigera)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Noctuelle de la tomate',
  'Helicoverpa armigera',
  'Chenille de 3-4cm, couleur variable (vert, brun, rose). Ravageur polyphage très destructeur.',
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
  'Lepidoptera',
  'Tomate, coton, maïs, pois chiche, sorgho',
  'Perforation des fruits, destruction des bourgeons',
  ARRAY['Trous dans les fruits', 'Excréments', 'Fleurs endommagées', 'Chenilles visibles']
);

-- 8. Aleurode du tabac (Bemisia argentifolii)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Aleurode du tabac',
  'Bemisia argentifolii',
  'Petit insecte blanc de 1mm, très similaire à Bemisia tabaci. Vecteur majeur de virus.',
  'https://images.unsplash.com/photo-1530587191325-3db32d826c18',
  'Hemiptera',
  'Tabac, tomate, coton, cucurbitacées',
  'Transmission de virus (TYLCV), affaiblissement',
  ARRAY['Nuage blanc', 'Jaunissement', 'Enroulement des feuilles', 'Nanisme']
);

-- 9. Pyrale du maïs (Ostrinia nubilalis)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Pyrale du maïs',
  'Ostrinia nubilalis',
  'Chenille de 2-3cm, beige avec tête brune. Fore des galeries dans les tiges et épis.',
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
  'Lepidoptera',
  'Maïs, sorgho, millet',
  'Casse des tiges, verse, perte de rendement',
  ARRAY['Trous dans les tiges', 'Sciure visible', 'Tiges cassées', 'Épis endommagés']
);

-- 10. Cicadelle verte (Empoasca vitis)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Cicadelle verte',
  'Empoasca vitis',
  'Petit insecte vert de 3mm, très mobile. Pique les feuilles pour se nourrir.',
  'https://images.unsplash.com/photo-1589820296156-2454bb8a6ad1',
  'Hemiptera',
  'Vigne, légumineuses, cultures maraîchères',
  'Jaunissement, nécrose marginale, chute des feuilles',
  ARRAY['Bords des feuilles jaunis', 'Feuilles recroquevillées', 'Insectes verts sauteurs']
);

-- 11. Charançon du bananier (Cosmopolites sordidus)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Charançon du bananier',
  'Cosmopolites sordidus',
  'Coléoptère noir de 10-15mm. Larves creusent des galeries dans le rhizome.',
  'https://images.unsplash.com/photo-1563089145-599997674d42',
  'Coleoptera',
  'Bananiers, plantains',
  'Affaiblissement, verse, mort du plant',
  ARRAY['Jaunissement des feuilles', 'Plant affaibli', 'Galeries dans le rhizome', 'Verse']
);

-- 12. Mouche des fruits (Ceratitis capitata)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Mouche méditerranéenne des fruits',
  'Ceratitis capitata',
  'Mouche de 4-5mm, thorax noir et jaune. Larves se développent dans les fruits.',
  'https://images.unsplash.com/photo-1530587191325-3db32d826c18',
  'Diptera',
  'Agrumes, fruits à noyau, fruits tropicaux',
  'Pourriture des fruits, chute prématurée',
  ARRAY['Piqûres sur fruits', 'Fruits pourris', 'Asticots dans fruits', 'Chute des fruits']
);

-- 13. Punaise verte (Nezara viridula)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Punaise verte',
  'Nezara viridula',
  'Punaise de 12-16mm, vert vif. Polyphage, pique les fruits et graines.',
  'https://images.unsplash.com/photo-1589820296156-2454bb8a6ad1',
  'Hemiptera',
  'Soja, tomate, haricot, cultures fruitières',
  'Déformation des fruits, avortement des graines',
  ARRAY['Piqûres sur fruits', 'Fruits déformés', 'Odeur désagréable', 'Taches sur fruits']
);

-- 14. Teigne de la pomme de terre (Phthorimaea operculella)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Teigne de la pomme de terre',
  'Phthorimaea operculella',
  'Petit papillon de 6mm. Chenilles minent les feuilles et tubercules.',
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
  'Lepidoptera',
  'Pomme de terre, tomate, aubergine',
  'Mines dans feuilles, galeries dans tubercules',
  ARRAY['Mines dans feuilles', 'Tubercules troués', 'Excréments', 'Feuilles desséchées']
);

-- 15. Criquet pèlerin (Schistocerca gregaria)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Criquet pèlerin',
  'Schistocerca gregaria',
  'Grand criquet de 5-7cm, jaune-brun. Forme des essaims dévastateurs.',
  'https://images.unsplash.com/photo-1563089145-599997674d42',
  'Orthoptera',
  'Céréales, cultures fourragères, prairies',
  'Défoliation totale, destruction massive des cultures',
  ARRAY['Essaims visibles', 'Défoliation rapide', 'Bruit caractéristique', 'Cultures rasées']
);

-- 16. Coccinelle asiatique (Harmonia axyridis) - AUXILIAIRE
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Coccinelle asiatique',
  'Harmonia axyridis',
  'Coccinelle de 5-8mm, orange avec points noirs variables. Prédateur efficace de pucerons.',
  'https://images.unsplash.com/photo-1563089145-599997674d42',
  'Coleoptera',
  'Cultures diverses, jardins, vergers',
  'Aucun - insecte auxiliaire bénéfique',
  ARRAY['Présence de coccinelles', 'Réduction des pucerons', 'Larves noires et oranges']
);

-- 17. Chrysope verte (Chrysoperla carnea) - AUXILIAIRE
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Chrysope verte',
  'Chrysoperla carnea',
  'Insecte délicat de 10-15mm, vert pâle, ailes transparentes. Larves prédatrices de pucerons.',
  'https://images.unsplash.com/photo-1530587191325-3db32d826c18',
  'Neuroptera',
  'Cultures diverses, jardins',
  'Aucun - insecte auxiliaire bénéfique',
  ARRAY['Adultes verts délicats', 'Larves prédatrices', 'Réduction des ravageurs']
);

-- 18. Syrphe (Episyrphus balteatus) - AUXILIAIRE
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Syrphe',
  'Episyrphus balteatus',
  'Mouche de 10mm ressemblant à une guêpe. Larves prédatrices de pucerons.',
  'https://images.unsplash.com/photo-1530587191325-3db32d826c18',
  'Diptera',
  'Cultures diverses, jardins, prairies fleuries',
  'Aucun - insecte auxiliaire bénéfique',
  ARRAY['Mouches rayées', 'Vol stationnaire', 'Larves vertes', 'Réduction des pucerons']
);

-- 19. Acarien rouge (Tetranychus urticae)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Acarien tisserand',
  'Tetranychus urticae',
  'Minuscule acarien de 0.5mm, rouge-orangé. Tisse des toiles fines. Très polyphage.',
  'https://images.unsplash.com/photo-1589820296156-2454bb8a6ad1',
  'Acari',
  'Cultures maraîchères, arbres fruitiers, ornementales',
  'Décoloration, dessèchement, chute des feuilles',
  ARRAY['Toiles fines', 'Points jaunes sur feuilles', 'Feuilles desséchées', 'Décoloration']
);

-- 20. Mineuse de la tomate (Tuta absoluta)
INSERT INTO insects (common_name, scientific_name, description, image_url, category, habitat, damage, symptoms)
VALUES (
  'Mineuse de la tomate',
  'Tuta absoluta',
  'Petit papillon de 5mm. Chenilles minent les feuilles, tiges et fruits. Ravageur majeur.',
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
  'Lepidoptera',
  'Tomate, pomme de terre, aubergine',
  'Mines dans feuilles, galeries dans fruits et tiges',
  ARRAY['Mines serpentines', 'Fruits troués', 'Feuilles desséchées', 'Excréments noirs']
);

-- ============================================
-- TRAITEMENTS ASSOCIÉS
-- ============================================

-- Traitements pour Puceron vert du pêcher
INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Savon noir', 'Pulvérisation de savon noir dilué à 5%. Asphyxie les pucerons.', 'biological', 4, 'Dès apparition, tous les 3-5 jours', 5.00
FROM insects WHERE common_name = 'Puceron vert du pêcher';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Coccinelles', 'Lâcher de coccinelles prédatrices (50-100/plante)', 'biological', 5, 'Prévention au printemps', 30.00
FROM insects WHERE common_name = 'Puceron vert du pêcher';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Pyréthrine naturelle', 'Insecticide botanique à base de pyrèthre', 'biological', 4, 'En cas de forte infestation', 15.00
FROM insects WHERE common_name = 'Puceron vert du pêcher';

-- Traitements pour Doryphore
INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Ramassage manuel', 'Collecte manuelle des adultes et larves, destruction des œufs', 'mechanical', 4, 'Quotidien en début d''infestation', 0.00
FROM insects WHERE common_name = 'Doryphore';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Bacillus thuringiensis', 'Bactérie spécifique des larves de coléoptères', 'biological', 5, 'Stade larvaire jeune', 20.00
FROM insects WHERE common_name = 'Doryphore';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Rotation des cultures', 'Alterner avec des non-solanacées pendant 2-3 ans', 'cultural', 4, 'Planification annuelle', 0.00
FROM insects WHERE common_name = 'Doryphore';

-- Traitements pour Chenille légionnaire
INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Bacillus thuringiensis', 'Pulvérisation de Bt spécifique lépidoptères', 'biological', 5, 'Stade larvaire précoce', 25.00
FROM insects WHERE common_name = 'Chenille légionnaire d''automne';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Phéromones', 'Pièges à phéromones pour capturer les mâles', 'biological', 4, 'Avant la ponte', 40.00
FROM insects WHERE common_name = 'Chenille légionnaire d''automne';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Neem', 'Huile de neem, répulsif et perturbateur de croissance', 'biological', 3, 'Dès détection', 18.00
FROM insects WHERE common_name = 'Chenille légionnaire d''automne';

-- Traitements pour Mouche blanche
INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Pièges jaunes collants', 'Plaques jaunes engluées pour capture massive', 'mechanical', 3, 'En continu', 10.00
FROM insects WHERE common_name = 'Mouche blanche';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Encarsia formosa', 'Parasitoïde spécifique des mouches blanches', 'biological', 5, 'Prévention sous serre', 50.00
FROM insects WHERE common_name = 'Mouche blanche';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Savon insecticide', 'Pulvérisation de savon potassique', 'biological', 4, 'Tous les 5-7 jours', 12.00
FROM insects WHERE common_name = 'Mouche blanche';

-- Traitements pour Thrips
INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Pièges bleus collants', 'Plaques bleues engluées attractives', 'mechanical', 3, 'En continu', 10.00
FROM insects WHERE common_name = 'Thrips des fleurs';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Amblyseius cucumeris', 'Acarien prédateur de thrips', 'biological', 5, 'Prévention', 45.00
FROM insects WHERE common_name = 'Thrips des fleurs';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Spinosad', 'Insecticide d''origine naturelle (bactérie)', 'biological', 4, 'En cas d''infestation', 22.00
FROM insects WHERE common_name = 'Thrips des fleurs';

-- Traitements pour Mineuse de la tomate
INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Filets anti-insectes', 'Protection physique des cultures', 'mechanical', 5, 'Installation permanente', 100.00
FROM insects WHERE common_name = 'Mineuse de la tomate';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Trichogramma', 'Parasitoïde des œufs de mineuse', 'biological', 4, 'Lâchers hebdomadaires', 35.00
FROM insects WHERE common_name = 'Mineuse de la tomate';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Destruction des plants infestés', 'Élimination et brûlage des plants touchés', 'cultural', 4, 'Dès détection', 0.00
FROM insects WHERE common_name = 'Mineuse de la tomate';

-- Traitements pour Acarien rouge
INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Phytoseiulus persimilis', 'Acarien prédateur spécifique', 'biological', 5, 'Dès apparition', 40.00
FROM insects WHERE common_name = 'Acarien tisserand';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Pulvérisation d''eau', 'Jet d''eau pour déloger les acariens', 'mechanical', 3, 'Quotidien', 0.00
FROM insects WHERE common_name = 'Acarien tisserand';

INSERT INTO traitements (insect_id, methode, description, type, efficacite, periode_application, cout_estime)
SELECT id, 'Soufre mouillable', 'Acaricide naturel', 'biological', 4, 'Tous les 10-14 jours', 15.00
FROM insects WHERE common_name = 'Acarien tisserand';

-- ============================================
-- VÉRIFICATION
-- ============================================

-- Compter les insectes ajoutés
SELECT COUNT(*) as total_insects FROM insects;

-- Compter les traitements ajoutés
SELECT COUNT(*) as total_traitements FROM traitements;

-- Voir les insectes avec leurs traitements
SELECT 
    i.common_name,
    i.category,
    COUNT(t.id) as nombre_traitements
FROM insects i
LEFT JOIN traitements t ON i.id = t.insect_id
GROUP BY i.id, i.common_name, i.category
ORDER BY i.common_name;
