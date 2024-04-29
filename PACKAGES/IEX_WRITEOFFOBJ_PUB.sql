--------------------------------------------------------
--  DDL for Package IEX_WRITEOFFOBJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WRITEOFFOBJ_PUB" AUTHID CURRENT_USER as
/* $Header: iexpwros.pls 120.4 2007/10/31 14:55:04 ehuh ship $ */
-- Start of Comments
-- Package name     :IEX_WRITEOFFOBJ_PUB
-- Purpose          : 1) Procedure to populate OKL_TRX_ADJST_B and OKL_TXL_ADJSTS_LNS_B
--                  : 2) Procedure to call OKL_WRAPPER OKL_CREATE_ADJ_PVT
--                  :    to create an adjustment
--                  : 3) Procedure to check approval before creating a writeoff.
--                  : 4) Procedure to update iex_writeoff_objects after creating
--                  :    the adjustment.
--
-- NOTE             :
-- End of Comments

subtype writeoff_rec_type         is IEX_writeoffs_PVT.writeoffs_Rec_Type;
subtype writeoff_obj_rec_type         is iex_writeoff_objects_pub.writeoff_obj_rec_type;
g_miss_writeoff_obj_rec_type          writeoff_obj_rec_type ;

subtype adjv_rec_type is OKL_TRX_AR_ADJSTS_PUB.adjv_rec_type;
subtype ajlv_rec_type is OKL_TXL_ADJSTS_LNS_PUB.ajlv_rec_type;

------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME              CONSTANT VARCHAR2(200) := 'IEX_WRITEOFFOBJ_PUB';
 G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_DEFAULT_NUM_REC_FETCH CONSTANT NUMBER := 30;
 G_YES                   CONSTANT VARCHAR2(1) := 'Y';
 G_NO                    CONSTANT VARCHAR2(1) := 'N';
------------------------------------------------------------------------------

PROCEDURE create_writeoffs(
     P_Api_Version_Number           IN   NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,p_commit                       IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,p_writeoff_object_rec          IN   writeoff_obj_rec_type
                                         := g_miss_writeoff_obj_rec_type
    ,p_writeoff_type                IN VARCHAR2
    ,p_object_id                    IN VARCHAR2
    ,p_invoice_line_id              in number
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,x_adjustment_id                OUT  NOCOPY NUMBER
    );

/** this is called from the form to get messages from the stack
 */
 PROCEDURE Get_Messages (
   p_message_count IN  NUMBER,
   x_message       OUT NOCOPY VARCHAR2);

/** this is called from the form to get messages from the stack
 */
 PROCEDURE Get_Messages1 (
   p_message_count IN  NUMBER,
   x_message       OUT NOCOPY VARCHAR2);

/**
  called from the workflow to approve writeoffs
  the approval
 **/

  PROCEDURE approve_writeoffs (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               result       out nocopy varchar2);


  PROCEDURE reject_writeoffs (itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              result       out nocopy varchar2);

 PROCEDURE  invoke_writeoff_wf(
                     p_WRITEOFF_ID     IN NUMBER
                    ,p_writeoff_type   IN VARCHAR2
                    ,p_request_id      IN NUMBER
                    ,p_object_id       IN VARCHAR2
              	    ,x_return_status   OUT NOCOPY VARCHAR2
                    ,x_msg_count       OUT NOCOPY NUMBER
                    ,x_msg_data        OUT NOCOPY VARCHAR2 );

  FUNCTION INIT_WRITEOFFOBJ_REC RETURN IEX_WRITEOFFOBJ_PUB.writeoff_obj_rec_type ;

END IEX_WRITEOFFOBJ_PUB;

/
