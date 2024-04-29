--------------------------------------------------------
--  DDL for Package OPIMPXWP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPIMPXWP" AUTHID CURRENT_USER AS
/*$Header: OPIMXWPS.pls 120.1 2005/06/08 18:32:28 appldev  $ */

PROCEDURE calc_wip_balance(
          I_ORG_ID                        IN   NUMBER,
          I_PUSH_START_INV_TXN_DATE       IN   DATE,
          I_PUSH_START_WIP_TXN_DATE       IN   DATE,
          I_PUSH_LAST_INV_TXN_ID          IN   NUMBER,
          I_PUSH_LAST_WIP_TXN_ID          IN   NUMBER,
          I_PUSH_END_TXN_DATE             IN   DATE,
          I_FIRST_PUSH                    IN   NUMBER,
          O_ERR_NUM                      OUT  NOCOPY NUMBER,
          O_ERR_CODE                     OUT  NOCOPY VARCHAR2,
          O_ERR_MSG                      OUT  NOCOPY VARCHAR2
         );

PROCEDURE calc_beginning_wip(
   i_org_id                    IN     NUMBER,
   i_push_start_wip_txn_date   IN     DATE,
   o_err_num                   OUT  NOCOPY  NUMBER,
   o_err_code                  OUT  NOCOPY  VARCHAR2,
   o_err_msg                   OUT  NOCOPY  VARCHAR2
   );

PROCEDURE upd_first_push_wip(
      i_ids_key        IN  VARCHAR2,
      i_org_id         IN  NUMBER,
      i_item_id        IN  NUMBER,
      i_revision       IN  VARCHAR2,
      i_txn_date       IN  DATE,
      i_wip_amount     IN  NUMBER,
      i_update_flag    IN  NUMBER,    -- (1=update bal , 2=substract from bal)
      o_err_num        OUT NOCOPY NUMBER,
      o_err_code       OUT NOCOPY VARCHAR2,
      o_err_msg        OUT NOCOPY VARCHAR2
      );

PROCEDURE update_daily_wip(
      i_ids_key        IN  VARCHAR2,
      i_org_id         IN  NUMBER,
      i_item_id        IN  NUMBER,
      i_revision       IN  VARCHAR2,
      i_txn_date       IN  DATE,
      i_wip_amount     IN  NUMBER,
      o_err_num        OUT NOCOPY NUMBER,
      o_err_code       OUT NOCOPY VARCHAR2,
      o_err_msg        OUT NOCOPY VARCHAR2
      );

FUNCTION get_prev_end_bal(
      i_ids_key        IN  VARCHAR2,
      i_org_id         IN  NUMBER,
      i_item_id        IN  NUMBER,
      i_revision       IN  VARCHAR2,
      i_txn_date       IN  DATE,
      o_err_num        OUT NOCOPY NUMBER,
      o_err_code       OUT NOCOPY VARCHAR2,
      o_err_msg        OUT NOCOPY VARCHAR2
      ) return number;

END OPIMPXWP;

 

/
