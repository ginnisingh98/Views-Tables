--------------------------------------------------------
--  DDL for Package CN_GET_SRP_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_SRP_DATA_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvsfgts.pls 115.6 2002/11/21 21:18:29 hlchen ship $*/

TYPE srp_data_rec_type IS RECORD
  (srp_id                 NUMBER,
   name                   CN_SRP_HR_DATA.NAME%TYPE,
   emp_num                CN_SRP_HR_DATA.EMP_NUM%TYPE,
   start_date             DATE,
   end_date               DATE,
   cost_center            VARCHAR2(30),
   comp_group_id          NUMBER,
   comp_group_name        CN_QM_MGR_SRP_GROUPS.GROUP_NAME%TYPE,
   job_code               VARCHAR2(240),
   job_title              VARCHAR2(240),
   disc_job_title         VARCHAR2(80),
   role_id                NUMBER,
   role_name              CN_QM_MGR_SRP_GROUPS.ROLE_NAME%TYPE);

TYPE srp_data_tbl_type IS TABLE OF srp_data_rec_type
  INDEX BY binary_integer;

-- Get_Srp_List returns a list of all the salesreps
PROCEDURE Get_Srp_List
  (x_srp_data                   OUT NOCOPY    srp_data_tbl_type);

-- Search_Srp_Data returns all the salesreps from cn_srp_hr_data along with
-- their current job title (using p_date) and comp group assignment.  You can
-- search over four criteria (name, job title, emp num, and comp group).
-- Search is case insensitive and nulls are returned (for % query).
PROCEDURE Search_Srp_Data
  (p_range_low                  IN     NUMBER,
   p_range_high                 IN     NUMBER,
   p_date                       IN     DATE,
   p_search_name                IN     VARCHAR2 := '%',
   p_search_job                 IN     VARCHAR2 := '%',
   p_search_emp_num             IN     VARCHAR2 := '%',
   p_search_group               IN     VARCHAR2 := '%',
   p_order_by                   IN     NUMBER   := 1,
   p_order_dir                  IN     VARCHAR2 := 'ASC',
   x_total_rows                 OUT NOCOPY    NUMBER,
   x_srp_data                   OUT NOCOPY    srp_data_tbl_type);

-- Get_Srp_Data returns the salesrep information for a given salesrep
PROCEDURE Get_Srp_Data
  (p_srp_id                     IN     NUMBER,
   x_srp_data                   OUT NOCOPY    srp_data_tbl_type);

-- Get_Managers returns all the managers assigned to a given salesrep and
-- comp group for a given date
PROCEDURE Get_Managers
  (p_srp_id                     IN     NUMBER,
   p_date                       IN     DATE,
   p_comp_group_id              IN     NUMBER,
   x_srp_data                   OUT NOCOPY    srp_data_tbl_type);

END CN_GET_SRP_DATA_PVT;

 

/
