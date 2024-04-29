--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_CCA_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_CCA_OPM_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDEICCAPS.pls 120.1 2005/08/02 04:54:06 visgupta noship $ */

/**************************************************
* Package Level Constants
**************************************************/

C_PRER12_SOURCE CONSTANT NUMBER := 3;
C_OPM_CCA_MARKER CONSTANT VARCHAR2(6) := 'OPMCCA';
C_CCA_MARKER CONSTANT VARCHAR2(3) := 'CCA';
C_PKG_NAME CONSTANT VARCHAR2 (50) := 'opi_dbi_inv_cca_opm_pkg';
C_ERRBUF_SIZE CONSTANT NUMBER := 300;

/**************************************************
* Public Procedures
**************************************************/

/* run_initial_load_opm

    Wrapper routine for the initial load of the cycle count accuracy ETL.

    Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning
    p_degree  - Is it still needed?

    History:
    Date        Author              Action
    04/03/04    Vedhanarayanan G    Defined specification.

*/
PROCEDURE run_initial_load_opm (errbuf    in out NOCOPY  VARCHAR2,
                                retcode   in out NOCOPY  NUMBER);


/* get_unit_cost

   Wrapper function for gmf_cmcomman.unit_cost with parallel enabled.

   History:
   Date        Author              Action
   03/06/04    Vedhanarayanan G    Defined specification.

*/
FUNCTION get_unit_cost(p_item_id IN NUMBER,
                       p_whse_code IN VARCHAR2,
                       p_orgn_code IN VARCHAR2,
                       p_creation_date IN DATE)
         RETURN NUMBER
         PARALLEL_ENABLE;

END opi_dbi_inv_cca_opm_pkg;

 

/
