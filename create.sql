CREATE TABLE "Software" (
  "software_id" INT,
  "name"        VARCHAR(16),
  "version"     NUMERIC(4, 2),
  PRIMARY KEY ("software_id")
);

CREATE TABLE "Validator" (
  "validator" VARCHAR(10),
  PRIMARY KEY ("validator")
);

CREATE TABLE "Validators" (
  "relationship_id" INT,
  "validator"       VARCHAR(10) references "Validator",
  "software_id"     INT references "Software" (software_id),
  PRIMARY KEY ("relationship_id")
);

CREATE TABLE "System" (
  "system_id" INT,
  "validator" VARCHAR(10) references "Validator",
  "hostname"  VARCHAR(20),
  PRIMARY KEY ("system_id")
);

CREATE TABLE "Aggregator" (
  "aggregator_id" INT,
  "system_id"     INT references "System" (system_id),
  "ip_address"    VARCHAR(15),
  "username"      VARCHAR(16),
  "password"      VARCHAR(30),
  PRIMARY KEY ("aggregator_id")
);

CREATE TABLE "Device" (
  "device_id"     INT,
  "software_id"   INT references "Software" (software_id),
  "aggregator_id" INT references "Aggregator" (aggregator_id),
  "type"          VARCHAR(16),
  "ip_address"    VARCHAR(15),
  "username"      VARCHAR(16),
  "password"      VARCHAR(30),
  PRIMARY KEY ("device_id")
);

CREATE VIEW "Devices in Systems" AS
  SELECT
    system_id,
    device_id,
    type as device_type,
    "Device".software_id
  FROM "System"
    JOIN "Aggregator" USING (system_id)
    JOIN "Device" USING (aggregator_id)
    JOIN "Software" S2 on "Device".software_id = S2.software_id;

CREATE TABLE "Software Releases" (
  "release_date" DATE,
  "software_id"  INT references "Software" (software_id),
  PRIMARY KEY ("software_id")
);

CREATE OR REPLACE FUNCTION public.log_software_release()
  RETURNS TRIGGER as $$
BEGIN
  INSERT INTO "Software Releases" VALUES (current_date, NEW.software_id);
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER log_update
  AFTER INSERT
  ON "Software"
  FOR EACH ROW
EXECUTE PROCEDURE public.log_software_release();

INSERT INTO "Software" (software_id, name, version) VALUES
  (1, 'Windows', 7.0),
  (2, 'Windows', 10.0),
  (3, 'Android', 4.0),
  (4, 'Linux', 3.0),
  (5, 'iOS', 9.1),
  (6, 'iOS', 9.8),
  (7, 'Mac OS', 12.0);

INSERT INTO "Validator" (validator) VALUES
  ('VALID_1'),
  ('VALID_2'),
  ('VALID_3');

INSERT INTO "Validators" (relationship_id, validator, software_id) VALUES
  (1, 'VALID_1', 1),
  (2, 'VALID_1', 2),
  (3, 'VALID_2', 3),
  (4, 'VALID_2', 4),
  (5, 'VALID_3', 4),
  (6, 'VALID_3', 5),
  (7, 'VALID_3', 6),
  (8, 'VALID_3', 7);

INSERT INTO "System" (system_id, validator, hostname) VALUES
  (1, 'VALID_1', 'microsoft.com'),
  (2, 'VALID_1', 'github.com'),
  (3, 'VALID_2', 'google.com'),
  (4, 'VALID_2', 'android.com'),
  (5, 'VALID_3', 'apple.com');

INSERT INTO "Aggregator" (aggregator_id, system_id, ip_address, username, password) VALUES
  (1, 1, '10.0.1.1', 'bill', 'P`y`w`7{(,xhF2h<'),
  (2, 2, '10.0.2.1', 'bill', 'B5t+<K5\ZEHZSaqU'),
  (3, 3, '10.1.1.1', 'linus', 'Jz9=G!={c(?rgL/6'),
  (4, 3, '10.1.2.1', 'linus', 'Jz9=G!={c(?rgL/6'),
  (5, 4, '10.1.3.1', 'linus', '%>vDk7(AaJx]B"@='),
  (6, 5, '10.2.1.1', 'tim', 'B9Z}<bu+BTt''@2JL'),
  (7, 5, '10.2.2.1', 'tim', 'B9Z}<bu+BTt''@2JL'),
  (8, 5, '10.2.3.1', 'tim', 'B9Z}<bu+BTt''@2JL'),
  (9, 5, '10.2.4.1', 'tim', '\4@cucz[,.Z37mG*');

INSERT INTO "Device" (device_id, software_id, aggregator_id, type, ip_address, username, password) VALUES
  (1, 1, 1, 'PC', '10.0.1.100', 'vasya1', 'zsDTPtVh'),
  (2, 2, 1, 'PC', '10.0.1.101', 'trololo', 'FPGLXY3G'),
  (3, 1, 2, 'Laptop', '10.0.2.100', 'admin', 'c6UcnuMx'),
  (4, 3, 3, 'Phone', '10.1.1.100', 'jacek', 'TVtB6t5j'),
  (5, 4, 3, 'PC', '10.1.1.101', 'root', 'HjhtdzLS'),
  (6, 4, 4, 'PC', '10.1.2.100', 'tomek', 'tmfhDPRV'),
  (7, 3, 5, 'Tablet', '10.1.3.100', 'root', 'Z6DbmUw3'),
  (8, 5, 6, 'iPhone', '10.2.1.100', 'root', 'WAXqhSkp'),
  (9, 6, 6, 'iPhone', '10.2.1.101', 'root', '8VvUQb6G'),
  (10, 6, 7, 'iPad', '10.2.2.100', 'root', 'aXcGUBYr'),
  (11, 6, 7, 'iWatch', '10.2.2.101', 'bob', 'TgVJ7xnM'),
  (12, 7, 8, 'iMac', '10.2.3.100', 'guest', 'KzuFJJkw'),
  (13, 7, 8, 'iMac', '10.2.3.101', 'admAdm', 'KGB9Zd5B'),
  (14, 7, 9, 'MacBook', '10.2.4.100', 'ewa', 'vK5G5KZs'),
  (15, 7, 9, 'MacBook', '10.2.4.101', 'marcin', 'uGPueHmF');
