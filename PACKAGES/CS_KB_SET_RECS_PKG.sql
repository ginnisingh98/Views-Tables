--------------------------------------------------------
--  DDL for Package CS_KB_SET_RECS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SET_RECS_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbsrs.pls 115.6 2003/08/30 00:50:27 speng ship $ */

  /* for return status */
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;


  PROCEDURE Move_Up_Solution_Rec
  ( p_set_rec_id in number,
    x_ret_status out nocopy varchar2,
    x_msg_count  out nocopy number,
    x_msg_data   out nocopy varchar2 );

  PROCEDURE Move_Down_Solution_Rec
  ( p_set_rec_id in number,
    x_ret_status out nocopy varchar2,
    x_msg_count  out nocopy number,
    x_msg_data   out nocopy varchar2 );

  PROCEDURE Create_Set_Rec
  ( P_SET_REC_ID         in NUMBER DEFAULT NULL,
    P_SET_NUMBER         in VARCHAR2,
    P_SET_ORDER          in NUMBER DEFAULT NULL,
    P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE1         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE2         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE3         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE4         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE5         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE6         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE7         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE8         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE9         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE10        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE11        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE12        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE13        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE14        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE15        in VARCHAR2 DEFAULT NULL,
    X_SET_REC_ID         out nocopy NUMBER,
    X_RET_STATUS         out nocopy VARCHAR2,
    X_MSG_COUNT          out nocopy NUMBER,
    X_MSG_DATA           out nocopy VARCHAR2 );

  procedure Update_Set_Rec
  ( P_SET_REC_ID         in NUMBER,
    P_SET_NUMBER         in VARCHAR2,
    P_SET_ORDER          in NUMBER,
    P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE1         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE2         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE3         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE4         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE5         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE6         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE7         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE8         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE9         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE10        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE11        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE12        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE13        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE14        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE15        in VARCHAR2 DEFAULT NULL,
    X_RET_STATUS         out nocopy VARCHAR2,
    X_MSG_COUNT          out nocopy NUMBER,
    X_MSG_DATA           out nocopy VARCHAR2 );

  PROCEDURE Delete_Set_Rec
  ( p_set_rec_id in  number,
    x_ret_status out nocopy varchar2,
    x_msg_count  out nocopy number,
    x_msg_data   out nocopy varchar2 );

end CS_KB_SET_RECS_PKG;

 

/
