--------------------------------------------------------
--  DDL for Package Body IGW_GR_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_GR_MIGRATION" AS
--$Header: igwgrmigrationb.pls 120.3 2005/09/30 00:54:54 ashkumar ship $

   ---------------------------------------------------------------------------

   g_package_name CONSTANT  VARCHAR2(30) := 'IGW_GR_MIGRATION';
   g_igw_literal          CONSTANT  VARCHAR2(30) := 'IGW';
   g_stage                  VARCHAR2(500);
   g_user_id                NUMBER(15);
   g_login_id               NUMBER(15);
   g_currency_code          VARCHAR2(30);
   g_fiscal_year_start_mmdd VARCHAR2(30);
   g_budget_template_id     NUMBER;

   ---------------------------------------------------------------------------

   PROCEDURE Proposal_Migration
   (
      errbuf  OUT NOCOPY VARCHAR2,
      retcode OUT NOCOPY NUMBER
   ) IS
   BEGIN
	NULL;

END Proposal_Migration;

   ---------------------------------------------------------------------------

   PROCEDURE Security_Migration
   (
      x_msg_data      OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   ) IS

   BEGIN
	NULL;

END Security_Migration;

   ---------------------------------------------------------------------------

   PROCEDURE Budget_Migration
   (
      p_init_msg_list IN VARCHAR2,
      p_validate_only IN VARCHAR2,
      p_commit        IN VARCHAR2,
      p_proposal_id   IN NUMBER,
      p_version_id    IN NUMBER,
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_count     OUT NOCOPY NUMBER,
      x_msg_data      OUT NOCOPY VARCHAR2
   ) IS

   BEGIN
	NULL;

END Budget_Migration;

   ---------------------------------------------------------------------------

   FUNCTION Get_Latest_Version_Id(p_proposal_id NUMBER) RETURN NUMBER IS

      l_api_name CONSTANT VARCHAR2(30) := 'Get_Latest_Version_Id';

      l_version_id NUMBER;

   BEGIN

      RETURN null;

   END Get_Latest_Version_Id;

   ---------------------------------------------------------------------------

   PROCEDURE Log(p_log_msg IN VARCHAR2) IS
   BEGIN

      NULL;

   END Log;

   ---------------------------------------------------------------------------

   PROCEDURE Set_Stage(p_stage IN VARCHAR2) IS
   BEGIN

      g_stage := p_stage;
      Log('');
      Log('Migration Stage : '||g_stage||'...');

   END Set_Stage;

   ---------------------------------------------------------------------------

   PROCEDURE Display_Rowcount IS
   BEGIN

      Log(SQL%ROWCOUNT||' rows migrated in '||g_stage);

   END Display_Rowcount;

   ---------------------------------------------------------------------------

   PROCEDURE Execute_Commit IS
   BEGIN

      Log('**** Committing data...');
      COMMIT;
      Log('DATA COMMITTED');

   END Execute_Commit;

   ---------------------------------------------------------------------------

   FUNCTION Get_Location_Code(p_budget_vers_exp_category_id NUMBER) RETURN VARCHAR2 IS

   BEGIN

      RETURN null;

   END Get_Location_Code;

  ---------------------------------------------------------------------------

   FUNCTION Get_Oh_Eb_Flag
   (
      p_budget_vers_exp_category_id NUMBER,
      p_rate_class_type VARCHAR2
   )
   RETURN VARCHAR2 IS

   BEGIN


      RETURN null;

   END Get_Oh_Eb_Flag;

   ---------------------------------------------------------------------------

END Igw_Gr_Migration;

/
