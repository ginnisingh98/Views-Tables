--------------------------------------------------------
--  DDL for Package IGW_GR_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_GR_MIGRATION" AUTHID CURRENT_USER AS
--$Header: igwgrmigrations.pls 120.0 2005/06/16 23:01:47 vmedikon ship $

   ---------------------------------------------------------------------------

   PROCEDURE Proposal_Migration
   (
      errbuf  OUT NOCOPY VARCHAR2,
      retcode OUT NOCOPY NUMBER
   );

   ---------------------------------------------------------------------------

   PROCEDURE Security_Migration
   (
      x_msg_data      OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   );

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
   );

   ---------------------------------------------------------------------------

   FUNCTION Get_Latest_Version_Id(p_proposal_id NUMBER) RETURN NUMBER;

   ---------------------------------------------------------------------------

   FUNCTION Get_Location_Code(p_budget_vers_exp_category_id NUMBER) RETURN VARCHAR2;

   ---------------------------------------------------------------------------

   FUNCTION Get_Oh_Eb_Flag
   (
      p_budget_vers_exp_category_id NUMBER,
      p_rate_class_type VARCHAR2
   )
   RETURN VARCHAR2;

   ---------------------------------------------------------------------------

   PROCEDURE Log(p_log_msg IN VARCHAR2);

   ---------------------------------------------------------------------------

   PROCEDURE Set_Stage(p_stage IN VARCHAR2);

   ---------------------------------------------------------------------------

   PROCEDURE Display_Rowcount;

   ---------------------------------------------------------------------------

   PROCEDURE Execute_Commit;

   ---------------------------------------------------------------------------

END Igw_Gr_Migration;

 

/
