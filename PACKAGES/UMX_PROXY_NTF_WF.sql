--------------------------------------------------------
--  DDL for Package UMX_PROXY_NTF_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_PROXY_NTF_WF" AUTHID CURRENT_USER as
/*$Header: UMXVPNTS.pls 120.0.12010000.3 2017/11/10 03:57:34 avelu ship $*/

  /**
   * Procedure   :  LAUNCH_WORKFLOW
   * Type        :  Private
   * Pre_reqs    :  WF_ENGINE.CREATEPROCESS, WF_ENGINE.SETITEMATTRTEXT, and
   *                WF_ENGINE.STARTPROCESS.
   * Description :  Create and Start workflow process
   * Parameters  :
   * input parameters
   * @param
   *   p_proxy_username
   *     description:  FND user's username.  The recipient of the notification.
   *     required   :  N
   *     validation :  Must be a valid FND User.
   *     default    :  null
   *   p_start_date
   *     description:  Date when the proxy privilege begins
   *     required   :  Y
   *   p_end_date
   *     description:  Date when the proxy privilege ends
   *     required   :  N
   * output parameters
   * @return
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  PROCEDURE LAUNCH_WORKFLOW (p_proxy_username  in varchar2,
                             p_start_date      in date,
                             p_end_date        in date default null,
        		     p_notes 	       in varchar2 default null);


end UMX_PROXY_NTF_WF;

/
