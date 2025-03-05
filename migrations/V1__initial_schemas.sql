-- 1. Students
CREATE TABLE students (
    student_id     SERIAL PRIMARY KEY,
    cognito_info   TEXT,
    name           TEXT NOT NULL,
    profile_photo  TEXT,
    start_year     INT,
    graduation_year INT,
    address        TEXT
);

-- 2. Programs
CREATE TABLE programs (
    program_id   SERIAL PRIMARY KEY,
    program_name TEXT,
    director     TEXT
);

-- 3. Courses
CREATE TABLE courses (
    course_id    SERIAL PRIMARY KEY,
    course_code  VARCHAR(50) NOT NULL,
    course_name  TEXT        NOT NULL,
    credits      INT         NOT NULL,
    semester     VARCHAR(10) -- optional if it's fixed; could also move to a student-course table
);

-- 4. Program ↔ Courses (Linking table for many-to-many)
CREATE TABLE program_courses (
    program_id INT NOT NULL,
    course_id  INT NOT NULL,
    PRIMARY KEY (program_id, course_id),
    FOREIGN KEY (program_id) REFERENCES programs (program_id),
    FOREIGN KEY (course_id)  REFERENCES courses (course_id)
);

-- 5. Enrollments (Student ↔ Program)
--    If each student can enroll in multiple programs (or vice versa),
--    and you want to track attributes (like overall GPA) at the program level.
CREATE TABLE enrollments (
    enrollment_id     SERIAL PRIMARY KEY,
    student_id        INT NOT NULL,
    program_id        INT NOT NULL,
    gpa               NUMERIC(4,2),    -- Example for storing a GPA up to 9.99
    enrollment_status TEXT,
    start_date        DATE,
    FOREIGN KEY (student_id) REFERENCES students (student_id),
    FOREIGN KEY (program_id) REFERENCES programs (program_id)
);

-- 6. Student ↔ Course Enrollment
--    Tracks when a student is enrolled in a specific course, possibly
--    within a certain program. Include grade, semester, etc. if needed.
CREATE TABLE student_course_enrollment (
    student_course_enrollment_id SERIAL PRIMARY KEY,
    student_id  INT NOT NULL,
    course_id   INT NOT NULL,
    program_id  INT, -- optional if you need to know which program the course belongs to
    grade       VARCHAR(2),
    status      VARCHAR(20),
    semester    VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES students (student_id),
    FOREIGN KEY (course_id)  REFERENCES courses (course_id),
    FOREIGN KEY (program_id) REFERENCES programs (program_id)
);

-- 7. Usage Info (LLM credits)
--    If you only need a single record per student storing total usage or
--    remaining credits, this simple table will do.
CREATE TABLE usage_info (
    student_id        INT PRIMARY KEY,
    credits_available INT NOT NULL,
    credits_used      INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students (student_id)
);