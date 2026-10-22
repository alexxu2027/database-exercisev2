-- =====================================================================
-- Database exercise: class intake survey
-- Database schema (PostgreSQL)
--
-- Source: data/class_dataset.csv (23 students, one row per student)
--
-- Five tables:
--   students              one row per student
--   tools                 one row per tool (Python, Excel, SQL, ...)
--   student_tools         which student uses which tool
--   time_slots            one row per time slot (Weekday mornings, ...)
--   student_availability  which student is free in which time slot
--
-- Why the bridge tables: the CSV's "tools" and "availability" columns
-- hold several values per cell, joined by semicolons. A student uses
-- many tools and a tool is used by many students (many-to-many), so
-- each pairing gets its own row instead of living in one text column.
--
-- Safe to run more than once: every table uses IF NOT EXISTS.
-- Create order matters: parent tables before the bridge tables.
-- =====================================================================


-- ---------------------------------------------------------------------
-- students
-- One row per survey response. Everything that has a single value per
-- student stays here.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS students (
    student_id             SERIAL        PRIMARY KEY,   -- generated ID; names can repeat, so they can't be the key
    netid                  VARCHAR(32)   NOT NULL UNIQUE,
        -- NOTE: the CSV mixes formats (jq2306, yo2162@nyu.edu, N16059079, Ks7532).
        -- Team to decide: clean them (strip @nyu.edu, lowercase) before loading, or keep as-is.
    name                   VARCHAR(255)  NOT NULL,
    school_year            VARCHAR(16)   NOT NULL
        CHECK (school_year IN ('First-year', 'Sophomore', 'Junior', 'Senior')),
    intro_programming      VARCHAR(16)   NOT NULL
        CHECK (intro_programming IN ('took_it', 'equivalent', 'neither')),
    skill_programming      SMALLINT      NOT NULL CHECK (skill_programming     BETWEEN 1 AND 5),
    skill_data_stats       SMALLINT      NOT NULL CHECK (skill_data_stats      BETWEEN 1 AND 5),
    skill_frontend_design  SMALLINT      NOT NULL CHECK (skill_frontend_design BETWEEN 1 AND 5),
    skill_business_pitch   SMALLINT      NOT NULL CHECK (skill_business_pitch  BETWEEN 1 AND 5),
    working_style          TEXT,                        -- free-text answers
    interests              TEXT,
    semester_goal          TEXT,
    submitted_at           TIMESTAMPTZ   NOT NULL       -- when the survey was submitted (stored in UTC)
);


-- ---------------------------------------------------------------------
-- tools
-- The list of tools students can pick. In the CSV: Python, Excel, SQL,
-- JavaScript, R.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tools (
    tool_id  SERIAL       PRIMARY KEY,
    name     VARCHAR(64)  NOT NULL UNIQUE               -- e.g. "Python"
);


-- ---------------------------------------------------------------------
-- student_tools  (bridge: students <-> tools)
-- One row per student per tool they use.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS student_tools (
    student_id  INTEGER  NOT NULL REFERENCES students (student_id) ON DELETE CASCADE,
    tool_id     INTEGER  NOT NULL REFERENCES tools (tool_id),
    PRIMARY KEY (student_id, tool_id)                   -- a student can't list the same tool twice
);


-- ---------------------------------------------------------------------
-- time_slots
-- The availability options. In the CSV: Weekday / Weekend x
-- mornings / afternoons / evenings (6 slots).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS time_slots (
    slot_id  SERIAL       PRIMARY KEY,
    name     VARCHAR(64)  NOT NULL UNIQUE               -- e.g. "Weekend afternoons"
);


-- ---------------------------------------------------------------------
-- student_availability  (bridge: students <-> time_slots)
-- One row per student per time slot they are free.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS student_availability (
    student_id  INTEGER  NOT NULL REFERENCES students (student_id) ON DELETE CASCADE,
    slot_id     INTEGER  NOT NULL REFERENCES time_slots (slot_id),
    PRIMARY KEY (student_id, slot_id)
);
