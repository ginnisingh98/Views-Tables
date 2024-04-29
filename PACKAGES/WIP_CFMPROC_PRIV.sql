--------------------------------------------------------
--  DDL for Package WIP_CFMPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CFMPROC_PRIV" AUTHID CURRENT_USER as
/* $Header: wipcfmps.pls 120.0.12000000.1 2007/01/18 22:13:59 appldev ship $ */

  /**
   * This procedure process a single flow/work orderless transaction.
   */
  procedure processTemp(p_initMsgList  in  varchar2,
                        p_txnTempID    in  number,
                        x_returnStatus out nocopy varchar2);

  /**
   * This procedure process a single flow/work orderless transaction inserted
   * by the mobile application.
   */
  procedure processMobile(p_txnHdrID     in number,
                          p_txnTmpID    in  number,
                          p_processInv   in  varchar2,
                          x_returnStatus out nocopy varchar2,
                          x_errorMessage out nocopy varchar2);

end wip_cfmProc_priv;

 

/
