-- Script de Migration des Images vers Supabase Storage
-- CropGuardian - Migration des URLs Pinterest vers Supabase

-- ============================================
-- ÉTAPE 1: Créer le bucket (à faire dans Supabase UI ou via SQL)
-- ============================================

-- Créer le bucket pour les images d'insectes
INSERT INTO storage.buckets (id, name, public)
VALUES ('insect_images', 'insect_images', true)
ON CONFLICT (id) DO NOTHING;

-- Définir les politiques d'accès (lecture publique)
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'insect_images');

-- Politique pour l'upload (seulement les utilisateurs authentifiés)
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'insect_images' AND auth.role() = 'authenticated');

-- ============================================
-- ÉTAPE 2: Sauvegarder les URLs actuelles
-- ============================================

-- Créer une table temporaire pour backup
CREATE TABLE IF NOT EXISTS insects_image_backup AS
SELECT id, common_name, image_url, NOW() as backup_date
FROM insects
WHERE image_url IS NOT NULL;

-- ============================================
-- ÉTAPE 3: Template pour mettre à jour les URLs
-- ============================================

-- IMPORTANT: Remplacez YOUR_PROJECT par votre vrai projet Supabase
-- Format: https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/FILENAME.jpg

-- Exemple pour quelques insectes communs:

-- Puceron (Aphid)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/aphid.jpg'
WHERE id = 'aphid' OR common_name ILIKE '%puceron%' OR common_name ILIKE '%aphid%';

-- Mouche blanche (Whitefly)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/whitefly.jpg'
WHERE id = 'whitefly' OR common_name ILIKE '%mouche blanche%' OR common_name ILIKE '%whitefly%';

-- Chenille (Caterpillar)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/caterpillar.jpg'
WHERE id = 'caterpillar' OR common_name ILIKE '%chenille%' OR common_name ILIKE '%caterpillar%';

-- Coccinelle (Ladybug)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/ladybug.jpg'
WHERE id = 'ladybug' OR common_name ILIKE '%coccinelle%' OR common_name ILIKE '%ladybug%';

-- Criquet (Grasshopper)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/grasshopper.jpg'
WHERE id = 'grasshopper' OR common_name ILIKE '%criquet%' OR common_name ILIKE '%grasshopper%';

-- Abeille (Bee)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/bee.jpg'
WHERE id = 'bee' OR common_name ILIKE '%abeille%' OR common_name ILIKE '%bee%';

-- Fourmi (Ant)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/ant.jpg'
WHERE id = 'ant' OR common_name ILIKE '%fourmi%' OR common_name ILIKE '%ant%';

-- Papillon (Butterfly)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/butterfly.jpg'
WHERE id = 'butterfly' OR common_name ILIKE '%papillon%' OR common_name ILIKE '%butterfly%';

-- Moustique (Mosquito)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/mosquito.jpg'
WHERE id = 'mosquito' OR common_name ILIKE '%moustique%' OR common_name ILIKE '%mosquito%';

-- Scarabée (Beetle)
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/beetle.jpg'
WHERE id = 'beetle' OR common_name ILIKE '%scarabée%' OR common_name ILIKE '%beetle%';

-- ============================================
-- ÉTAPE 4: Vérification
-- ============================================

-- Voir tous les insectes avec leurs nouvelles URLs
SELECT 
    id,
    common_name,
    image_url,
    CASE 
        WHEN image_url LIKE '%supabase%' THEN '✅ Migré'
        WHEN image_url LIKE '%pinterest%' THEN '⚠️ Pinterest'
        WHEN image_url LIKE '%pinimg%' THEN '⚠️ Pinterest'
        ELSE '❓ Autre'
    END as status
FROM insects
ORDER BY status, common_name;

-- Compter les images par source
SELECT 
    CASE 
        WHEN image_url LIKE '%supabase%' THEN 'Supabase'
        WHEN image_url LIKE '%pinterest%' OR image_url LIKE '%pinimg%' THEN 'Pinterest'
        WHEN image_url LIKE '%unsplash%' THEN 'Unsplash'
        WHEN image_url LIKE '%pexels%' THEN 'Pexels'
        WHEN image_url IS NULL THEN 'Pas d''image'
        ELSE 'Autre'
    END as source,
    COUNT(*) as count
FROM insects
GROUP BY source
ORDER BY count DESC;

-- ============================================
-- ÉTAPE 5: Rollback (si nécessaire)
-- ============================================

-- Restaurer les URLs d'origine depuis le backup
-- ATTENTION: Ceci annule toutes les modifications !
/*
UPDATE insects i
SET image_url = b.image_url
FROM insects_image_backup b
WHERE i.id = b.id;
*/

-- ============================================
-- ÉTAPE 6: Nettoyage (après vérification)
-- ============================================

-- Supprimer la table de backup (seulement quand tout fonctionne)
-- DROP TABLE IF EXISTS insects_image_backup;

-- ============================================
-- NOTES IMPORTANTES
-- ============================================

/*
1. AVANT D'EXÉCUTER:
   - Créer le bucket 'insect_images' dans Supabase Storage
   - Télécharger et uploader toutes les images
   - Remplacer YOUR_PROJECT par votre vrai projet

2. NOMMAGE DES FICHIERS:
   - Utiliser des noms simples: aphid.jpg, whitefly.jpg
   - Pas d'espaces, pas de caractères spéciaux
   - Extensions: .jpg, .png, .webp

3. FORMAT DES URLs:
   https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/FILENAME.jpg

4. TAILLE DES IMAGES:
   - Recommandé: 800x600 pixels
   - Format: JPEG (meilleure compression)
   - Poids: < 200KB par image

5. SOURCES D'IMAGES RECOMMANDÉES:
   - Unsplash: https://unsplash.com/s/photos/insects
   - Pexels: https://www.pexels.com/search/insects/
   - Wikimedia: https://commons.wikimedia.org
   - iNaturalist: https://www.inaturalist.org

6. VÉRIFICATION:
   - Tester chaque URL dans un navigateur
   - Vérifier que l'image s'affiche
   - Vérifier les permissions du bucket
*/

-- ============================================
-- EXEMPLE COMPLET POUR UN INSECTE
-- ============================================

/*
-- 1. Télécharger l'image
wget "https://images.unsplash.com/photo-..." -O aphid.jpg

-- 2. Optimiser l'image (optionnel)
convert aphid.jpg -resize 800x600 -quality 85 aphid_optimized.jpg

-- 3. Upload vers Supabase (via UI ou API)
-- Dans Supabase Storage > insect_images > Upload

-- 4. Mettre à jour la base de données
UPDATE insects 
SET image_url = 'https://YOUR_PROJECT.supabase.co/storage/v1/object/public/insect_images/aphid.jpg'
WHERE id = 'aphid';

-- 5. Vérifier
SELECT id, common_name, image_url FROM insects WHERE id = 'aphid';
*/
