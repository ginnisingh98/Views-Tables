--------------------------------------------------------
--  DDL for Package CN_UPGRADE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_UPGRADE_UTL_PKG" AUTHID CURRENT_USER as
/* $Header: cnuputls.pls 120.1.12010000.4 2010/06/25 09:24:47 rnagaraj ship $ */

  FUNCTION get_start_date(p_period_id NUMBER,
			  p_org_id    NUMBER) RETURN DATE ;

  PRAGMA RESTRICT_REFERENCES (get_start_date,WNDS,WNPS);

  FUNCTION get_end_date(p_period_id NUMBER,
			p_org_id    NUMBER) RETURN DATE;

  PRAGMA RESTRICT_REFERENCES (get_end_date,WNDS,WNPS);


--| ---------------------------------------------------------------------+
--| Function Name :  is_release_11510
--| Desc : Check if current release is 11.5.10
--| Return 1 if current release is 11.5.10
--| Return 0 if current release is 10.7, 3i or 11.0, 11.5
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_11510 RETURN NUMBER;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_115
--| Desc : Check if current release is 11.5
--| Return 1 if current release is 11.5
--| Return 0 if current release is 10.7, 3i or 11.0
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_115 RETURN NUMBER;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_107
--| Desc : Check if current release is 10.7
--| Return 1 if current release is 10.7
--| Return 0 if current release is 11.5,3i or 11.0
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+


FUNCTION is_release_120 RETURN NUMBER;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_120
--| Desc : Check if current release is 120
--| Return 1 if current release is 120
--| Return -1 : not valid release
--| ---------------

FUNCTION is_release_107 RETURN NUMBER ;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_110
--| Desc : Check if current release is 11.0
--| Return 1 if current release is 11.0
--| Return 0 if current release is 10.7,3i or 11.0 or 11.5
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_110 RETURN NUMBER ;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_3i
--| Desc : Check if current release is 3i
--| Return 1 if current release is 3i
--| Return 0 if current release is 10.7,11.0 or 11.5
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_3i RETURN NUMBER ;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_121
--| Desc : Check if current release is 121
--| Return 1 if current release is 121
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_121 RETURN NUMBER;



--| ---------------------------------------------------------------------+
--| Procedure Name :  CNCMAUPD_R1212
--| Desc           :  To improve the performance of Credit Allocation CP,
--|                   NVL(cn_comm_lines_api_all.adjust_status,NEW) and
--|                   NVL(cn_comm_lines_api_all.preserve_credit_override_flag,N)
--|                   need to be performed and this is done via the concurrent
--|                   program CN_R1212_CNCMAUPD - reference to bugs.,
--|                   9725647 and 9737110.
--| ---------------------------------------------------------------------+
PROCEDURE CNCMAUPD_R1212 (
                  x_errbuf        OUT NOCOPY VARCHAR2,
                  x_retcode       OUT NOCOPY VARCHAR2,
                  p_batch_size     IN NUMBER,
                  p_num_workers    IN NUMBER,
                  p_worker_id      IN NUMBER);



--| ---------------------------------------------------------------------+
--| Procedure Name :  CNCMHUPD_R1212
--| Desc           :  To improve the performance of Credit Allocation CP,
--|                   NVL(cn_commission_headers_all.adjust_status,NEW) need
--|                   to be performed and this is done via the concurrent
--|                   program CN_R1212_CNCMHUPD - reference to bugs.,
--|                   9725883 and 9737110.
--| ---------------------------------------------------------------------+
PROCEDURE CNCMHUPD_R1212 (
                  x_errbuf        OUT NOCOPY VARCHAR2,
                  x_retcode       OUT NOCOPY VARCHAR2,
                  p_batch_size     IN NUMBER,
                  p_num_workers    IN NUMBER,
                  p_worker_id      IN NUMBER);




END  cn_upgrade_utl_pkg;

/
