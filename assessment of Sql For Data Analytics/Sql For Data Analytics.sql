create database  Healthcare_Appointments;
use  Healthcare_Appointments;

CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(10)
);


CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL
);


CREATE TABLE appointments (
    app_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    app_date DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);


CREATE TABLE prescriptions (
    pres_id INT PRIMARY KEY AUTO_INCREMENT,
    app_id INT,
    medicine VARCHAR(100) NOT NULL,
    dosage_mg INT NOT NULL,
    FOREIGN KEY (app_id) REFERENCES appointments(app_id)
);


-- 1
SELECT d.doctor_id,
       d.name,
       COUNT(a.app_id) AS total_appointments
FROM doctors d
left join appointments a
ON d.doctor_id = a.doctor_id
WHERE a.app_date >= CURDATE() - INTERVAL 30 DAY
GROUP BY d.doctor_id, d.name
ORDER BY total_appointments DESC;

-- 2
SELECT d.department,
       COUNT(DISTINCT a.patient_id) AS total_patients
FROM doctors d
left JOIN appointments a
ON d.doctor_id = a.doctor_id
GROUP BY d.department;

-- 3
SELECT medicine,
       COUNT(*) AS prescription_count
FROM prescriptions
GROUP BY medicine
ORDER BY prescription_count DESC
LIMIT 1;

-- 4
SELECT p.patient_id,
       p.name,
       COUNT(DISTINCT d.department) AS dept_count
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY p.patient_id, p.name
HAVING dept_count > 2;

-- 5
SELECT 
    COUNT(a.app_id) / COUNT(DISTINCT p.patient_id) 
    AS avg_appointments_per_patient
FROM patients p
LEFT JOIN appointments a
ON p.patient_id = a.patient_id;

-- 6
SELECT d.doctor_id,
       d.name,
       COUNT(DISTINCT pr.medicine) AS medicine_count
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN prescriptions pr ON a.app_id = pr.app_id
GROUP BY d.doctor_id, d.name
HAVING medicine_count > 5;

-- 7
SELECT dosage_mg,
       COUNT(*) AS usage_count
FROM prescriptions
WHERE medicine = 'Paracetamol'
GROUP BY dosage_mg
ORDER BY usage_count DESC
LIMIT 3;

-- 8
SELECT patient_id,
       AVG(days_gap) AS avg_days_between_appointments
FROM (
    SELECT patient_id,
           DATEDIFF(
               app_date,
               LAG(app_date) OVER (PARTITION BY patient_id ORDER BY app_date)
           ) AS days_gap
    FROM appointments
) t
WHERE days_gap IS NOT NULL
GROUP BY patient_id;

-- 9
SELECT p.patient_id,
       p.name,
       COUNT(DISTINCT DATE_FORMAT(a.app_date, '%Y-%m')) AS month_count
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.name
HAVING month_count >= 3;

-- 10
SELECT d.department,
       COUNT(DISTINCT a.patient_id) AS unique_patients
FROM doctors d
JOIN appointments a
ON d.doctor_id = a.doctor_id
GROUP BY d.department
ORDER BY unique_patients DESC
LIMIT 1;


















