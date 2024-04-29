--------------------------------------------------------
--  DDL for Package BEN_PDW_COPY_BEN_TO_STG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PDW_COPY_BEN_TO_STG" AUTHID CURRENT_USER AS
/* $Header: bepdwstg.pkh 120.7.12010000.1 2008/07/29 12:45:47 appldev ship $ */

    /*
        DEFINE CONSTANTS FOR ALL TABLES
    */
    TABLE_ALIAS_CPP VARCHAR2(3) := 'CPP';
    TABLE_ALIAS_PLN VARCHAR2(3) := 'PLN';
    TABLE_ALIAS_LPR VARCHAR2(4) := 'LPR1';

    DML_OPER_REUSE VARCHAR2(30) := 'REUSE';
    DML_OPER_INSER VARCHAR2(30) := 'INSERT';

    /*
      PROCEDURE TO COPY PLAN TYPE RECORD (BEN_PL_TYP_F)
      FROM BEN SCHEMA INTO STAGING TABLE
    */
    PROCEDURE copy_pl_typ_record
                       (p_pl_typ_id NUMBER,
                        p_effective_date DATE,
                        p_copy_entity_txn_id NUMBER,
                        p_business_group_id   Number,
                        p_copy_entity_result_id OUT NOCOPY NUMBER);


    /*
      PROCEDURE TO COPY PLAN RECORD (BEN_PL_F)
      FROM BEN SCHEMA INTO STAGING TABLE
      CALLS PLAN-COPY-PROCEDURE
    */
    PROCEDURE copy_pln_record_pcp
                        (p_effective_date DATE,
                         p_business_group_id NUMBER,
                         p_copy_entity_txn_id NUMBER);


    /*
      PROCEDURE TO REMOVE ALL DEPENDENT ROWS
      P_ID IS THE FOREING-KEY ID
      P_TABLE_ALIAS IS THE PARENT_TABLE_ALIAS
    */

    PROCEDURE remove_dpnt_rows
                        (p_copy_entity_txn_id NUMBER,
                         p_id NUMBER,
                         p_table_alias VARCHAR2);


    /*
      PROCEDURE TO COPY PLAN RECORD (BEN_PL_F)
      FROM BEN SCHEMA INTO STAGING TABLE
      COPIES PLN AND PL-TYP RECORDS

    PROCEDURE copy_pln_record_all
                        (p_pl_id NUMBER,
                         p_effective_date DATE,
                         p_business_group_id NUMBER,
                         p_copy_entity_txn_id NUMBER,
                         p_copy_entity_result_id OUT NOCOPY NUMBER,
                                                 p_ptp_copy_entity_result_id OUT NOCOPY NUMBER); */

   /** Procedure to Copy BEN-LER_F and all Child Records from BEN to Staging  */
   Procedure create_ler_result
      (
       p_validate                       in  number     default 0 -- false
      ,p_copy_entity_result_id          in  number
      ,p_copy_entity_txn_id             in  number    default null
      ,p_ler_id                         in  number    default null
      ,p_business_group_id              in  number    default null
      ,p_number_of_copies               in  number    default 0
      ,p_object_version_number          out nocopy number
      ,p_effective_date                 in  date
      )   ;
--
-- FOR PRTN ELPRO
--
               -- FUNCTION to return Elpro name , to be used in VO
FUNCTION get_prfl_name(
                       p_eligy_prfl_id IN Number
                      ,p_copy_entity_txn_id IN Number
                      )
RETURN VARCHAR2;

/* Function to return the proper lookup code for interim coverage */
FUNCTION Interim_Coverage_Lookup (
            lookupField in varchar2,
            lookupCd in varchar2
            )
RETURN varchar2;


              /* PROCEDURE to copy ELpro and its ctrt to staging
               This is a wrapper above plan copy api to avoid dupliactes*/
PROCEDURE create_elig_prfl_results(
                           p_copy_entity_txn_id IN NUMBER
                          ,p_prtn_elig_id       IN NUMBER

                         ) ;
  /* PROCEDURE to copy all Elpro's in Business Group and corresponding crtr to staging
               This is a wrapper above Plan Copy*/
PROCEDURE dump_elig_prfls(
                           p_copy_entity_txn_id IN NUMBER
                         ) ;
PROCEDURE create_vapro_results
                         (
                           p_copy_entity_txn_id IN NUMBER
                          ,p_vrbl_cvg_rt_id     IN NUMBER
                          ,p_vrbl_usg_code      IN VARCHAR2

                         );

FUNCTION get_dpnt_prfl_name(
                       p_eligy_prfl_id IN Number
                      ,p_copy_entity_txn_id IN Number
                      )
RETURN VARCHAR2;
procedure create_dep_elpro_results
(
    p_copy_entity_txn_id             in  number
   ,p_dpnt_dsgn_object_id            in  number
   ,p_dpnt_dsgn_level_code           in  varchar2
);

PROCEDURE copy_pln_record_pcp(p_effective_date DATE,
                                      p_business_group_id NUMBER,
                                      p_copy_entity_txn_id NUMBER,
                                      p_pl_Id  NUMBER);


Procedure Create_YRP_Result
(

   p_copy_entity_txn_id Number
  ,p_business_group_id  Number
  ,p_effective_date     Date

) ;


PROCEDURE pre_Processor(
   p_validate            Number
  , p_copy_entity_txn_id  Number
  ,p_business_group_id   Number
  ,p_effective_date      Date
  ,p_exception OUT NOCOPY Varchar2

 ) ;





procedure create_dep_elig_crtr_results
 (
   p_copy_entity_txn_id             in  number
  ,p_parent_entity_result_id        in  number
 ) ;
procedure create_elig_crtr_results
 (
   p_copy_entity_txn_id             in  number
  ,p_parent_entity_result_id        in  number
 ) ;

FUNCTION GET_BALANCE_NAME(
p_balance_id         IN Number,
p_bnft_balance_id IN NUMBER,
p_business_group_id  IN Number,
p_copy_entity_txn_id IN NUMBER,
p_effective_date     IN DATE )
RETURN VARCHAR2;

FUNCTION GET_CURRENCY(
p_currency_code IN VARCHAR2,
p_effective_date IN DATE
)
RETURN VARCHAR2;
Function get_stage_object_Name(
                p_copy_entity_txn_id IN NUMBER
               ,p_table_alias IN VARCHAR2
               ,p_information1 IN NUMBER
               )
Return VARCHAR2 ;
PROCEDURE copy_drvd_factor(
                p_copy_entity_txn_id IN NUMBER
               ,p_table_alias        IN VARCHAR2
               ,p_information1       IN NUMBER
               );
FUNCTION fetch_drvd_factor_result
(
 p_copy_entity_txn_id IN NUMBER
,p_table_alias        IN VARCHAR2
,p_information1       IN NUMBER
)
RETURN NUMBER;
PROCEDURE copy_bnft_bal(
p_copy_entity_txn_id IN NUMBER,
p_information1 IN NUMBER
);
procedure max_sequence(
        p_copy_entity_txn_id IN Number,
        p_effective_date IN Date,
        p_table_alias IN varchar2,
        p_plan_id IN Number,
        p_max_sequence OUT  NOCOPY Number
);


PROCEDURE create_program_result
(
     p_copy_entity_result_id       IN    NUMBER
     ,p_copy_entity_txn_id         IN    NUMBER
     ,p_pgm_id                     IN    NUMBER
     ,p_business_group_id          IN    NUMBER
     ,p_number_of_copies           IN    NUMBER
     ,p_object_version_number      IN    NUMBER
     ,p_effective_date             IN    DATE
     ,p_no_dup_rslt                IN    VARCHAR2
     );

PROCEDURE mark_future_data_exists(p_copy_entity_txn_id in NUMBER);

PROCEDURE copy_vrbl_rt_prfl(
	p_copy_entity_txn_id   IN  Number
	,p_business_group_id   IN  Number
	,p_effective_date IN Date
	,p_vrbl_rt_prfl_id IN Number
	,p_parent_result_id IN Number
);

Procedure create_elpro_result(
	  p_copy_entity_txn_id in Number,
      p_effective_date in Date,
      p_business_group_id in Number,
      p_elig_prfl_id in Number);

Procedure create_dep_elpro_result(
	  p_copy_entity_txn_id in Number,
      p_effective_date in Date,
      p_business_group_id in Number,
      p_dep_elig_prfl_id in Number);

FUNCTION get_COBRA_criteria_name(
    p_copy_entity_txn_id in Number,
    p_pgm_id in Number,
    p_ctp_id in Number
   )
RETURN VARCHAR2;

PROCEDURE populate_extra_mapping_ELP(
                        p_copy_entity_txn_id in Number,
                        p_effective_date in Date,
                        p_elig_prfl_id in Number
                        );

PROCEDURE  Create_Formula_FF_Result
		(
                p_validate IN Number
		,p_copy_entity_result_id      IN  Number
                ,p_copy_entity_txn_id	      IN  Number
                ,p_formula_id		      IN  Number
                ,p_business_group_id	      IN  Number
                ,p_number_of_copies    IN Number
                ,p_object_version_number OUT nocopy Number
                ,p_effective_date             IN  Date
                );
FUNCTION get_rule_name(
    p_copy_entity_txn_id in Number,
    p_id in Number,
    p_table_alias in Varchar2
   )
RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |-------------------------------< process >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
 -- This is the main batch procedure to be called from the concurrent manager.
--
   PROCEDURE process (
      errbuf                       OUT   NOCOPY      VARCHAR2
     ,retcode                      OUT   NOCOPY      NUMBER
     ,p_copy_entity_result_id      IN    NUMBER      DEFAULT NULL
     ,p_copy_entity_txn_id         IN    NUMBER
     ,p_pgm_id                     IN    NUMBER
     ,p_business_group_id          IN    NUMBER
     ,p_number_of_copies           IN    NUMBER
     ,p_object_version_number      IN    NUMBER      DEFAULT NULL
     ,p_effective_date             IN    VARCHAR2
     ,p_no_dup_rslt                IN    VARCHAR2
   );

PROCEDURE create_program_result
(
     p_copy_entity_result_id       IN    NUMBER
     ,p_copy_entity_txn_id         IN    NUMBER
     ,p_pgm_id                     IN    NUMBER
     ,p_business_group_id          IN    NUMBER
     ,p_number_of_copies           IN    NUMBER
     ,p_object_version_number      IN    NUMBER
     ,p_effective_date             IN    DATE
     ,p_no_dup_rslt                IN    VARCHAR2
     ,p_copy_mode                  IN    VARCHAR2
     ,p_request_id                 OUT   NOCOPY NUMBER
 );
procedure copy_elig_pzip_bnft_to_stg
(     p_copy_entity_txn_id       IN     NUMBER
     ,p_copy_mode                IN    VARCHAR2
     ,p_request_id               OUT   NOCOPY NUMBER
 );

 procedure copy_PostalZip_Bnft_Grp
(     p_copy_entity_txn_id       IN     NUMBER
 );

procedure copy_elig_pzip_bnftgrp (
      errbuf                       OUT   NOCOPY      VARCHAR2
     ,retcode                      OUT   NOCOPY      NUMBER
     ,p_copy_entity_txn_id      IN    NUMBER
   );

END BEN_PDW_COPY_BEN_TO_STG;

/
