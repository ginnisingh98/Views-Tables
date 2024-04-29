--------------------------------------------------------
--  DDL for Package CLN_UPDTDLVY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_UPDTDLVY_PKG" AUTHID CURRENT_USER AS
   /* $Header: CLNUPDLS.pls 115.4 2004/03/29 14:30:14 kkram noship $ */

   /*=======================================================================+
   | FILENAME
   |   CLNUPDLS.sql
   |
   | DESCRIPTION
   |   PL/SQL spec for package:  CLN_UPDTDLVY_PKG
   |
   | NOTES
   |   Created 10/26/03 chiung-fu.shih
   *=====================================================================*/

   PROCEDURE Get_Updatedelivery_Params(itemtype               IN              VARCHAR2,
                                       itemkey                IN              VARCHAR2,
                                       actid                  IN              NUMBER,
                                       funcmode               IN              VARCHAR2,
                                       resultout              IN OUT NOCOPY   VARCHAR2);

   PROCEDURE getReceiptNum(ReceiptNumAndMsgId   IN          VARCHAR2,
                           ReceiptNum           OUT  NOCOPY VARCHAR2);

   PROCEDURE Process_Update_Delivery   (p_receipt_id           IN              VARCHAR2,
                                        p_int_cnt_num          IN              NUMBER,
                                        p_delivery_num         IN              VARCHAR2,
                                        x_notification_code    IN OUT NOCOPY   VARCHAR2,
                                        x_doc_status           IN OUT NOCOPY   VARCHAR2);

   FUNCTION GET_FROM_ROLE_ORG_ID (P_SHIPMENT_HEADER_ID IN  NUMBER)
   RETURN  NUMBER;

END CLN_UPDTDLVY_PKG;

 

/
