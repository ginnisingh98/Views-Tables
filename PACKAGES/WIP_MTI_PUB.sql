--------------------------------------------------------
--  DDL for Package WIP_MTI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MTI_PUB" AUTHID CURRENT_USER as
/* $Header: wipmtivs.pls 120.0.12000000.1 2007/01/18 22:18:17 appldev ship $ */

  procedure preInvWIPProcessing(p_txnHeaderID  in  number,
                                x_returnStatus out nocopy varchar2);

  /**
   * This procedure do the general validation for the interface rows
   * under the given header id.
   */
  procedure validateInterfaceRows(p_txnHeaderID  in  number,
                                  x_returnStatus out nocopy varchar2);

  /**
   * This procedure do the wip specific validation for interface rows
   * under the given header id.
   */
  procedure postInvWIPValidation(p_txnHeaderID  in  number,
                                 x_returnStatus out nocopy varchar2);

  procedure postInvWIPProcessing(p_txnHeaderID  in number,
                                 p_txnBatchID   in number,
                                 x_returnStatus out nocopy varchar2);

  /**
   * This procedure sets the error status to the mti. It sets the error
   * for the given interface id as well as the child records.
   */
  procedure setMtiError(p_txnInterfaceID in number,
                        p_errCode        in varchar2,
                        p_msgData        in varchar2);

end wip_mti_pub;

 

/
