DROP VIEW "Devices in Systems";

DROP TRIGGER "log_update"
ON "Software";
DROP FUNCTION public.log_software_release();
DROP TABLE "Software Releases", "Device", "Aggregator", "System", "Validators", "Validator", "Software";