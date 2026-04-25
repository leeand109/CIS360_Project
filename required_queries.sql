-- Query 1: show fusion methods used for traffic/mobility-style data.
SELECT DISTINCT d.sensor_type, d.dataset_name, m.method_name, p.title
FROM datasets d
JOIN method_dataset_links mdl ON d.dataset_id = mdl.dataset_id
JOIN fusion_methods m ON mdl.method_id = m.method_id
JOIN papers p ON mdl.paper_id = p.paper_id
WHERE d.sensor_type ILIKE '%Mobility%'
   OR d.sensor_type ILIKE '%Mobile%'
   OR d.dataset_name ILIKE '%mobility%'
   OR d.dataset_name ILIKE '%phone%'
ORDER BY d.sensor_type, m.method_name;

-- Query 2: list papers that report U2 Measurement uncertainty for Satellite Imagery.
SELECT DISTINCT p.title, p.publication_year, d.dataset_name, d.sensor_type, u.uncertainty_type, u.description
FROM papers p
JOIN paper_uncertainties pu ON p.paper_id = pu.paper_id
JOIN uncertainties u ON pu.uncertainty_id = u.uncertainty_id
JOIN datasets d ON pu.dataset_id = d.dataset_id
WHERE u.uncertainty_type = 'U2'
  AND d.sensor_type = 'Satellite Imagery'
ORDER BY p.publication_year DESC;

-- Query 3: find the most popular dataset by number of linked methods.
SELECT d.dataset_name, d.sensor_type, COUNT(DISTINCT mdl.method_id) AS connected_method_count
FROM datasets d
JOIN method_dataset_links mdl ON d.dataset_id = mdl.dataset_id
GROUP BY d.dataset_id, d.dataset_name, d.sensor_type
ORDER BY connected_method_count DESC, d.dataset_name
LIMIT 10;

-- Query 4: linkage query, methods applied to both Dataset A and Dataset B.
SELECT m.method_name, COUNT(DISTINCT d.dataset_name) AS matched_dataset_count
FROM fusion_methods m
JOIN method_dataset_links mdl ON m.method_id = mdl.method_id
JOIN datasets d ON mdl.dataset_id = d.dataset_id
WHERE d.dataset_name IN (
    'Geo-tagged tweets and street network data',
    'Twitter, Flickr, and official migration data'
)
GROUP BY m.method_id, m.method_name
HAVING COUNT(DISTINCT d.dataset_name) = 2;

-- Query 5: which datasets are commonly fused with social/mobile data?
SELECT d1.dataset_name AS starting_dataset,
       d2.dataset_name AS related_dataset,
       p.title AS evidence_paper,
       m.method_name AS connecting_method
FROM datasets d1
JOIN method_dataset_links l1 ON d1.dataset_id = l1.dataset_id
JOIN method_dataset_links l2 ON l1.method_id = l2.method_id AND l1.paper_id = l2.paper_id
JOIN datasets d2 ON l2.dataset_id = d2.dataset_id AND d2.dataset_id <> d1.dataset_id
JOIN papers p ON l1.paper_id = p.paper_id
JOIN fusion_methods m ON l1.method_id = m.method_id
WHERE d1.dataset_name ILIKE '%Twitter%'
   OR d1.sensor_type ILIKE '%Social%'
   OR d1.sensor_type ILIKE '%Mobile%'
ORDER BY starting_dataset, related_dataset;
