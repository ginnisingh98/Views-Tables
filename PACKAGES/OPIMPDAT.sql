--------------------------------------------------------
--  DDL for Package OPIMPDAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPIMPDAT" AUTHID CURRENT_USER AS
/*$Header: OPIMDATS.pls 120.1 2005/06/10 17:31:28 appldev  $ */

procedure get_push_dates(
   I_ORG_ID                  IN    NUMBER,
   I_FROM_DATE               IN    DATE,
   I_TO_DATE                 IN    DATE,
   I_LAST_PUSH_MIN_DATE      IN    DATE,
   O_PUSH_START_INV_TXN_DATE OUT NOCOPY  DATE,
   O_PUSH_START_WIP_TXN_DATE OUT NOCOPY  DATE,
   O_PUSH_LAST_INV_TXN_ID    OUT NOCOPY  NUMBER,
   O_PUSH_LAST_WIP_TXN_ID    OUT NOCOPY  NUMBER,
   O_PUSH_LAST_INV_TXN_DATE  OUT NOCOPY  DATE,
   O_PUSH_LAST_WIP_TXN_DATE  OUT NOCOPY  DATE,
   O_PUSH_END_TXN_DATE       OUT NOCOPY  DATE,
   O_FIRST_PUSH              OUT NOCOPY  NUMBER,
   O_ERR_NUM                 OUT NOCOPY  NUMBER,
   O_ERR_CODE                OUT NOCOPY  VARCHAR2,
   O_ERR_MSG                 OUT NOCOPY  VARCHAR2,
   O_TXN_FLAG                OUT NOCOPY  NUMBER
);

procedure calc_from_date(
   i_org_id                 IN   NUMBER,
   i_from_date              IN   DATE,
   i_txn_date               IN   DATE,
   i_first_push             IN   NUMBER,
   o_calc_from_date         OUT NOCOPY DATE,
   o_err_num                OUT NOCOPY NUMBER,
   o_err_code               OUT NOCOPY VARCHAR2,
   o_err_msg                OUT NOCOPY VARCHAR2
);

END OPIMPDAT;

 

/
