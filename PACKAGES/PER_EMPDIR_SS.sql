--------------------------------------------------------
--  DDL for Package PER_EMPDIR_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EMPDIR_SS" AUTHID CURRENT_USER AS
/* $Header: peredrcp.pkh 120.2 2006/05/04 00:56 sspratur noship $ */

-- Global Variables
g_package       CONSTANT VARCHAR2(30):='PER_EMPDIR_SS';
g_commit_size   CONSTANT NUMBER:= 5000;
g_debug         Boolean:= false;
g_trace         Boolean:= false;
g_lang          VARCHAR2(10):= userenv('LANG');
g_request_id    NUMBER := nvl(fnd_global.conc_request_id,-1);
g_prog_appl_id  NUMBER := nvl(fnd_global.prog_appl_id,-1);
g_prog_id       NUMBER := nvl(fnd_global.conc_program_id,-1);
g_user_id       NUMBER := nvl(fnd_global.user_id,-1);
g_login_id      NUMBER := nvl(fnd_global.login_id, -1);
g_date          DATE := trunc(SYSDATE);

-- Memory structures

TYPE RowIdTblType IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE NumberTblType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VarChar10TblType IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE VarChar30TblType IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE VarChar45TblType IS TABLE OF VARCHAR2(45) INDEX BY BINARY_INTEGER;
TYPE VarChar60TblType IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;
TYPE VarChar80TblType IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE VarChar150TblType IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE VarChar240TblType IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE VarChar700TblType IS TABLE OF VARCHAR2(700) INDEX BY BINARY_INTEGER;
TYPE VarChar2000TblType IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE DateTblType IS TABLE OF DATE INDEX BY BINARY_INTEGER;

-- INDEX BY VARCHAR2 has 9i dependency

-- Record type definitions

TYPE PosTblType IS RECORD
  (orig_system              VarChar30TblType
  ,orig_system_id           NumberTblType
  ,business_group_id        NumberTblType
  ,legislation_code         VarChar30TblType
  ,job_id                   NumberTblType
  ,location_id              NumberTblType
  ,organization_id          NumberTblType
  ,position_definition_id   NumberTblType
  ,name                     VarChar240TblType
  ,language                 VarChar30TblType
  ,source_language          VarChar30TblType
  ,partition_id             NumberTblType
  ,object_version_number    NumberTblType
  ,attribute_category       VarChar30TblType
  ,attribute1               VarChar150TblType
  ,attribute2               VarChar150TblType
  ,attribute3               VarChar150TblType
  ,attribute4               VarChar150TblType
  ,attribute5               VarChar150TblType
  ,attribute6               VarChar150TblType
  ,attribute7               VarChar150TblType
  ,attribute8               VarChar150TblType
  ,attribute9               VarChar150TblType
  ,attribute10              VarChar150TblType
  ,attribute11              VarChar150TblType
  ,attribute12              VarChar150TblType
  ,attribute13              VarChar150TblType
  ,attribute14              VarChar150TblType
  ,attribute15              VarChar150TblType
  ,attribute16              VarChar150TblType
  ,attribute17              VarChar150TblType
  ,attribute18              VarChar150TblType
  ,attribute19              VarChar150TblType
  ,attribute20              VarChar150TblType
  ,attribute21              VarChar150TblType
  ,attribute22              VarChar150TblType
  ,attribute23              VarChar150TblType
  ,attribute24              VarChar150TblType
  ,attribute25              VarChar150TblType
  ,attribute26              VarChar150TblType
  ,attribute27              VarChar150TblType
  ,attribute28              VarChar150TblType
  ,attribute29              VarChar150TblType
  ,attribute30              VarChar150TblType
  ,information_category     VarChar30TblType
  ,information1             VarChar150TblType
  ,information2             VarChar150TblType
  ,information3             VarChar150TblType
  ,information4             VarChar150TblType
  ,information5             VarChar150TblType
  ,information6             VarChar150TblType
  ,information7             VarChar150TblType
  ,information8             VarChar150TblType
  ,information9             VarChar150TblType
  ,information10	    VarChar150TblType
  ,information11	    VarChar150TblType
  ,information12	    VarChar150TblType
  ,information13            VarChar150TblType
  ,information14            VarChar150TblType
  ,information15            VarChar150TblType
  ,information16            VarChar150TblType
  ,information17            VarChar150TblType
  ,information18            VarChar150TblType
  ,information19            VarChar150TblType
  ,information20            VarChar150TblType
  ,information21            VarChar150TblType
  ,information22            VarChar150TblType
  ,information23            VarChar150TblType
  ,information24            VarChar150TblType
  ,information25            VarChar150TblType
  ,information26            VarChar150TblType
  ,information27            VarChar150TblType
  ,information28            VarChar150TblType
  ,information29            VarChar150TblType
  ,information30            VarChar150TblType
  );

posTbl PosTblType;

TYPE JobTblType IS RECORD
  (orig_system              VarChar30TblType
  ,orig_system_id           NumberTblType
  ,business_group_id        NumberTblType
  ,legislation_code         VarChar30TblType
  ,job_definition_id        NumberTblType
  ,name                     VarChar700TblType
  ,display_name             VarChar240TblType
  ,language                 VarChar30TblType
  ,source_language          VarChar30TblType
  ,partition_id             NumberTblType
  ,object_version_number    NumberTblType
  ,attribute_category       VarChar30TblType
  ,attribute1               VarChar150TblType
  ,attribute2               VarChar150TblType
  ,attribute3               VarChar150TblType
  ,attribute4               VarChar150TblType
  ,attribute5               VarChar150TblType
  ,attribute6               VarChar150TblType
  ,attribute7               VarChar150TblType
  ,attribute8               VarChar150TblType
  ,attribute9               VarChar150TblType
  ,attribute10              VarChar150TblType
  ,attribute11              VarChar150TblType
  ,attribute12              VarChar150TblType
  ,attribute13              VarChar150TblType
  ,attribute14              VarChar150TblType
  ,attribute15              VarChar150TblType
  ,attribute16              VarChar150TblType
  ,attribute17              VarChar150TblType
  ,attribute18              VarChar150TblType
  ,attribute19              VarChar150TblType
  ,attribute20              VarChar150TblType
  ,job_information_category VarChar30TblType
  ,job_information1         VarChar150TblType
  ,job_information2         VarChar150TblType
  ,job_information          VarChar150TblType
  ,job_information4         VarChar150TblType
  ,job_information5         VarChar150TblType
  ,job_information6         VarChar150TblType
  ,job_information7         VarChar150TblType
  ,job_information8         VarChar150TblType
  ,job_information9         VarChar150TblType
  ,job_information10        VarChar150TblType
  ,job_information11        VarChar150TblType
  ,job_information12        VarChar150TblType
  ,job_information13        VarChar150TblType
  ,job_information14        VarChar150TblType
  ,job_information15        VarChar150TblType
  ,job_information16        VarChar150TblType
  ,job_information17        VarChar150TblType
  ,job_information18        VarChar150TblType
  ,job_information19        VarChar150TblType
  ,job_information20        VarChar150TblType
  );

jobTbl JobTblType;

TYPE CntTblType IS RECORD
  (row_id                   RowIdTblType
  ,orig_system              VarChar30TblType
  ,orig_system_id            NumberTblType
  ,cnt                      NumberTblType
  );

cntTbl CntTblType;

TYPE OrgTblType IS RECORD
  (orig_system              VarChar30TblType
  ,orig_system_id           NumberTblType
  ,business_group_id        NumberTblType
  ,legislation_code         VarChar30TblType
  ,location_id              NumberTblType
  ,representative1_id       NumberTblType
  ,representative2_id       NumberTblType
  ,representative3_id       NumberTblType
  ,representative4_id       NumberTblType
  ,name                     VarChar240TblType
  ,language                 VarChar10TblType
  ,source_lang              VarChar10TblType
  ,object_version_number    NumberTblType
  ,partition_id             NumberTblType
  ,attribute_category       VarChar30TblType
  ,attribute1               VarChar150TblType
  ,attribute2               VarChar150TblType
  ,attribute3               VarChar150TblType
  ,attribute4               VarChar150TblType
  ,attribute5               VarChar150TblType
  ,attribute6               VarChar150TblType
  ,attribute7               VarChar150TblType
  ,attribute8               VarChar150TblType
  ,attribute9               VarChar150TblType
  ,attribute10              VarChar150TblType
  ,attribute11              VarChar150TblType
  ,attribute12              VarChar150TblType
  ,attribute13              VarChar150TblType
  ,attribute14              VarChar150TblType
  ,attribute15              VarChar150TblType
  ,attribute16              VarChar150TblType
  ,attribute17              VarChar150TblType
  ,attribute18              VarChar150TblType
  ,attribute19              VarChar150TblType
  ,attribute20              VarChar150TblType);

orgTbl OrgTblType;

TYPE LocTblType IS RECORD
  (orig_system              VarChar30TblType
  ,orig_system_id           NumberTblType
  ,business_group_id        NumberTblType
  ,derived_locale           VarChar240TblType
  ,tax_name                 VarChar30TblType -- 15
  ,country                  VarChar60TblType
  ,style                    VarChar30TblType -- 7
  ,address                  VarChar2000TblType
  ,address_line_1           VarChar240TblType
  ,address_line_2           VarChar240TblType
  ,address_line_3           VarChar240TblType
  ,town_or_city             VarChar30TblType
  ,region_1                 VarChar150TblType -- 120
  ,region_2                 VarChar150TblType -- 120
  ,region_3                 VarChar150TblType -- 120
  ,postal_code              VarChar30TblType
  ,inactive_date            DateTblType
  ,office_site_flag         VarChar30TblType
  ,receiving_site_flag      VarChar30TblType
  ,telephone_number_1       VarChar60TblType
  ,telephone_number_2       VarChar60TblType
  ,telephone_number_3       VarChar60TblType
  ,timezone_id              NumberTblType
  ,timezone_code            VarChar60TblType  -- 50
  ,object_version_number    NumberTblType
  ,partition_id             NumberTblType
  );

locationTbl LocTblType;

TYPE AsgTblType IS RECORD
  (orig_system              VarChar30TblType
  ,orig_system_id           NumberTblType
  ,business_group_id        NumberTblType
  ,legislation_code         VarChar30TblType
  ,position_id              NumberTblType
  ,job_id                   NumberTblType
  ,location_id              NumberTblType
  ,supervisor_id            NumberTblType
  ,supervisor_assignment_id NumberTblType
  ,person_id                NumberTblType
  ,organization_id          NumberTblType
  ,primary_flag             VarChar30TblType
  ,active                   VarChar30TblType
  ,assignment_number        VarChar30TblType
  ,discretionary_title      VarChar240TblType
  ,employee_category        VarChar30TblType
  ,employment_category      VarChar30TblType
  ,assignment_category      VarChar30TblType
  ,work_at_home             VarChar30TblType
  ,object_version_number    NumberTblType
  ,partition_id             NumberTblType
  ,ass_attribute_category   VarChar30TblType
  ,ass_attribute1           VarChar150TblType
  ,ass_attribute2           VarChar150TblType
  ,ass_attribute3           VarChar150TblType
  ,ass_attribute4           VarChar150TblType
  ,ass_attribute5           VarChar150TblType
  ,ass_attribute6           VarChar150TblType
  ,ass_attribute7           VarChar150TblType
  ,ass_attribute8           VarChar150TblType
  ,ass_attribute9           VarChar150TblType
  ,ass_attribute10          VarChar150TblType
  ,ass_attribute11          VarChar150TblType
  ,ass_attribute12          VarChar150TblType
  ,ass_attribute13          VarChar150TblType
  ,ass_attribute14          VarChar150TblType
  ,ass_attribute15          VarChar150TblType
  ,ass_attribute16          VarChar150TblType
  ,ass_attribute17          VarChar150TblType
  ,ass_attribute18          VarChar150TblType
  ,ass_attribute19          VarChar150TblType
  ,ass_attribute20          VarChar150TblType
  ,ass_attribute21          VarChar150TblType
  ,ass_attribute22          VarChar150TblType
  ,ass_attribute23          VarChar150TblType
  ,ass_attribute24          VarChar150TblType
  ,ass_attribute25          VarChar150TblType
  ,ass_attribute26          VarChar150TblType
  ,ass_attribute27          VarChar150TblType
  ,ass_attribute28          VarChar150TblType
  ,ass_attribute29          VarChar150TblType
  ,ass_attribute30          VarChar150TblType);

asgTbl AsgTblType;

TYPE PersonTblType IS RECORD
  (row_id                   RowIdTblType
  ,person_key               VarChar2000TblType
  ,orig_system              VarChar30TblType
  ,orig_sytem_id            NumberTblType
  ,business_group_id        NumberTblType
  ,legislation_code         VarChar30TblType
  ,display_name             VarChar240TblType
  ,full_name                VarChar240TblType
  ,full_name_alternate      VarChar240TblType
  ,last_name                VarChar150TblType
  ,first_name               VarChar150TblType
  ,last_name_alternate      VarChar150TblType
  ,first_name_alternate     VarChar150TblType
  ,pre_name_adjunct         VarChar30TblType
  ,person_type              VarChar10TblType
  ,user_name                VarChar60TblType
  ,active                   VarChar30TblType
  ,employee_number          VarChar30TblType
  ,known_as                 VarChar80TblType
  ,middle_names             VarChar60TblType
  ,previous_last_name       VarChar150TblType
  ,start_date               DateTblType
  ,original_DOH             DateTblType
  ,email_address            VarChar240TblType
  ,work_telephone           VarChar60TblType
  ,mailstop                 VarChar45TblType
  ,office_number            VarChar45TblType
  ,order_name               VarChar240TblType
  ,partition_id             NumberTblType
  ,object_version_number    NumberTblType
  ,global_person_id         VarChar30TblType
  ,party_id                 NumberTblType
  ,attribute_category       VarChar30TblType
  ,attribute1               VarChar150TblType
  ,attribute2               VarChar150TblType
  ,attribute3               VarChar150TblType
  ,attribute4               VarChar150TblType
  ,attribute5               VarChar150TblType
  ,attribute6               VarChar150TblType
  ,attribute7               VarChar150TblType
  ,attribute8               VarChar150TblType
  ,attribute9               VarChar150TblType
  ,attribute10              VarChar150TblType
  ,attribute11              VarChar150TblType
  ,attribute12              VarChar150TblType
  ,attribute13              VarChar150TblType
  ,attribute14              VarChar150TblType
  ,attribute15              VarChar150TblType
  ,attribute16              VarChar150TblType
  ,attribute17              VarChar150TblType
  ,attribute18              VarChar150TblType
  ,attribute19              VarChar150TblType
  ,attribute20              VarChar150TblType
  ,attribute21              VarChar150TblType
  ,attribute22              VarChar150TblType
  ,attribute23              VarChar150TblType
  ,attribute24              VarChar150TblType
  ,attribute25              VarChar150TblType
  ,attribute26              VarChar150TblType
  ,attribute27              VarChar150TblType
  ,attribute28              VarChar150TblType
  ,attribute29              VarChar150TblType
  ,attribute30              VarChar150TblType
  ,per_information_category VarChar30TblType
  ,per_information1         VarChar150TblType
  ,per_information2         VarChar150TblType
  ,per_information3         VarChar150TblType
  ,per_information4         VarChar150TblType
  ,per_information5         VarChar150TblType
  ,per_information6         VarChar150TblType
  ,per_information7         VarChar150TblType
  ,per_information8         VarChar150TblType
  ,per_information9         VarChar150TblType
  ,per_information10        VarChar150TblType
  ,per_information11        VarChar150TblType
  ,per_information12        VarChar150TblType
  ,per_information13        VarChar150TblType
  ,per_information14        VarChar150TblType
  ,per_information15        VarChar150TblType
  ,per_information16        VarChar150TblType
  ,per_information17        VarChar150TblType
  ,per_information18        VarChar150TblType
  ,per_information19        VarChar150TblType
  ,per_information20        VarChar150TblType
  ,per_information21        VarChar150TblType
  ,per_information22        VarChar150TblType
  ,per_information23        VarChar150TblType
  ,per_information24        VarChar150TblType
  ,per_information25        VarChar150TblType
  ,per_information26        VarChar150TblType
  ,per_information27        VarChar150TblType
  ,per_information28        VarChar150TblType
  ,per_information29        VarChar150TblType
  ,per_information30        VarChar150TblType
  ,direct_reports           NumberTblType
  ,total_reports            NumberTblType
 );

personTbl PersonTblType;

-- ---------------------------------------------------------------------------
-- ---------------------------- < swap > -------------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This is a utility procedure for swaping two varchar2 data elements
-- ---------------------------------------------------------------------------

PROCEDURE swap(
   value1 IN OUT NOCOPY VARCHAR2
  ,value2 IN OUT NOCOPY VARCHAR2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < main > -------------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is invoked by PEREMPDIRREFRESH conc. prg.
--  p_mode: {COMPLETE, INCREMENTAL}
--  p_eff_date: Refresh date
--  p_soruce_system: Source system identifier
--  p_multi_asg: Process multiple assignments
--  p_refresh_images: Process images
-- ---------------------------------------------------------------------------

PROCEDURE main(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_mode  IN  VARCHAR2
  ,p_eff_date IN VARCHAR2
  ,p_source_system IN VARCHAR2
  ,p_multi_asg IN VARCHAR2 DEFAULT 'N'
  ,p_image_refresh IN VARCHAR2 DEFAULT 'N'
);

-- ---------------------------------------------------------------------------
-- ---------------------------- < write_log > --------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: Utility procedure for writting conc. prg. log
-- ---------------------------------------------------------------------------

PROCEDURE write_log(
   p_fpt IN NUMBER
  ,p_msg IN VARCHAR2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < compute_reports > --------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is invoked by PEREMPDIRCR conc. prg.
-- p_source_system: Source system identifier
-- ---------------------------------------------------------------------------

PROCEDURE compute_reports(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_source_system IN VARCHAR2
);

-- ---------------------------------------------------------------------------
-- ---------------------------- < get_timezone_id > --------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This function returns the timeZoneID given address location
-- ---------------------------------------------------------------------------

FUNCTION get_timezone_id(
  p_postal_code    IN   VARCHAR2,
  p_city           IN   VARCHAR2,
  p_state	   IN   VARCHAR2,
  p_country        IN   VARCHAR2
) RETURN NUMBER;

-- ---------------------------------------------------------------------------
-- ---------------------------- < get_timezone_id > --------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This function returns the timeZone Code based on the timeZoneId
-- derived for given address location
-- ---------------------------------------------------------------------------

FUNCTION get_timezone_code(
  p_postal_code    IN   VARCHAR2,
  p_city           IN   VARCHAR2,
  p_state		   IN   VARCHAR2,
  p_country        IN   VARCHAR2
) RETURN VARCHAR2;


-- ---------------------------------------------------------------------------
-- ---------------------------- < get_time > ---------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is invoked by the Online code for deriving the
-- local time give server and client timeZoneID's
-- ---------------------------------------------------------------------------

FUNCTION get_time (
   p_source_tz_id     IN NUMBER,
   p_dest_tz_id       IN NUMBER,
   p_source_day_time  IN DATE
) RETURN VARCHAR2;

-- ---------------------------------------------------------------------------
-- ---------------------------- < get_time > ---------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is invoked by the Online code for deriving the
-- local time given the client timeZoneID's. (server timezone is derived
-- using FND_TIMEZONES package.
-- ---------------------------------------------------------------------------
function get_time (
   p_to_tz in varchar2
) return varchar2;

END PER_EMPDIR_SS;

 

/
