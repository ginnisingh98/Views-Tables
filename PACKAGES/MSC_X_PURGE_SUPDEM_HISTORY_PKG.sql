--------------------------------------------------------
--  DDL for Package MSC_X_PURGE_SUPDEM_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_PURGE_SUPDEM_HISTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXPHSS.pls 120.1 2005/09/22 03:46:23 vdeshmuk noship $ */


PROCEDURE purge_sup_dem_history (
  p_errbuf              out nocopy varchar2,
  p_retcode             out nocopy varchar2,
  p_from_date           in varchar2     , /* changed from date to varchar2 bug# 4504227 */
  p_to_date             in varchar2     , /* changed from date to varchar2 bug# 4504227 */
  p_order_type		in Number
);


END msc_x_purge_supdem_history_pkg;

 

/
