--------------------------------------------------------
--  DDL for Package OPIMPXWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPIMPXWI" AUTHID CURRENT_USER AS
/*$Header: OPIMXWIS.pls 120.1 2005/06/08 18:31:09 appldev  $ */

g_org_error BOOLEAN := FALSE;
-- -----------------------------------------------------------
--  PROCEDURE PUSH
-- ---------------------------------------------------------

   Procedure  OPI_EXTRACT_IDS(p_from_date IN   DATE,
                              p_to_date   IN   DATE,
			      p_org_code  IN   VARCHAR2);


   Procedure CALC_INV_BALANCE(p_from_date   IN  Date,
                  p_to_date     IN  Date,
                  Org_id        IN  Number,
		  status       OUT nocopy NUMBER);

   Procedure Calculate_Balance( p_trx_date   IN DATE,
                p_organization_id  IN NUMBER,
                p_item_id          IN NUMBER,
                p_cost_group_id    IN NUMBER,
				p_edw_start_date   IN DATE,
                p_revision         IN VARCHAR2,
                p_lot_number       IN VARCHAR2,
                p_subinventory     IN VARCHAR2,
                p_locator          IN NUMBER,
                p_item_status      IN VARCHAR2,
                p_item_type        IN VARCHAR2,
                p_base_uom         IN VARCHAR2,
                p_total_qty        IN NUMBER,
                status             OUT nocopy NUMBER);

PROCEDURE purge_opi_ids_push_log(
                  i_org_id     IN   NUMBER,
                  o_errnum     OUT  nocopy NUMBER,
                  o_retcode    OUT  nocopy VARCHAR2,
                  o_errbuf     OUT  nocopy VARCHAR2);

PROCEDURE process_error(
          i_stmt_num     IN   NUMBER,
          i_errnum       IN   NUMBER,
          i_retcode      IN   VARCHAR2,
			i_errbuf       IN   VARCHAR2);

PROCEDURE process_warning(
          i_stmt_num     IN   NUMBER,
          i_errnum       IN   NUMBER,
          i_retcode      IN   VARCHAR2,
          i_errbuf       IN   VARCHAR2);

Procedure  calc_begin_inv(p_from_date IN   DATE,
                          Org_id IN Number,
                          status OUT nocopy Number);

PROCEDURE calc_intrst_balance(p_from_date   IN  Date,
                  p_to_date     IN  Date,
                  Org_id        IN  Number,
		  status       OUT nocopy Number);

End OPIMPXWI;

 

/
