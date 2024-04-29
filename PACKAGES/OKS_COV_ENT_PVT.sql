--------------------------------------------------------
--  DDL for Package OKS_COV_ENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COV_ENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRCENS.pls 120.0.12000000.1 2007/01/16 22:09:38 appldev ship $ */

-----------------------------------------------------------------------------------------------------------------------*

  SUBTYPE Gx_Boolean         IS VARCHAR2(1);
  SUBTYPE Gx_YesNo           IS VARCHAR2(1);
  SUBTYPE Gx_Ret_Sts         IS VARCHAR2(1);
  SUBTYPE Gx_ExceptionMsg    IS VARCHAR2(200);

-----------------------------------------------------------------------------------------------------------------------*

  SUBTYPE Gx_TimeZoneId      IS NUMBER; --OKX_TIMEZONES_V.TIMEZONE_ID%TYPE;
  SUBTYPE Gx_ReactDurn       IS NUMBER(15,2);--OKC_REACT_INTERVALS.DURATION%TYPE;
  SUBTYPE Gx_ReactUOM        IS VARCHAR2(3); --OKC_REACT_INTERVALS.UOM_CODE%TYPE;
  SUBTYPE Gx_OKS_Id          IS NUMBER;
  SUBTYPE Gx_BusProcess_Id   IS NUMBER; --OKX_BUS_PROCESSES_V.ID1%TYPE;
  SUBTYPE Gx_Severity_Id     IS NUMBER; --OKX_INCIDENT_SEVERITS_V.ID1%TYPE;

  SUBTYPE rcn_rsn_rec_type   IS OKS_COV_ENT_PUB.rcn_rsn_rec_type;
  SUBTYPE gdrt_inp_rec_type  IS OKS_COV_ENT_PUB.gdrt_inp_rec_type;

  G_RET_STS_SUCCESS        CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR	       CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR    CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_UNEXP_ERROR;

  G_TRUE                   CONSTANT Gx_Boolean    := OKC_API.G_TRUE;
  G_FALSE                  CONSTANT Gx_Boolean    := OKC_API.G_FALSE;

  G_REQUIRED_VALUE         CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE          CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;

  G_COL_NAME_TOKEN         CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN     CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD       CONSTANT VARCHAR2(200) := 'OKS_NO_PARENT_RECORD';

  G_UNEXPECTED_ERROR       CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN          CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';  --'SQLerrm';
  G_SQLCODE_TOKEN          CONSTANT VARCHAR2(200) := 'ERROR_CODE';     --'SQLcode';

  G_DEBUG_TOKEN            CONSTANT VARCHAR2(200) := 'OKS_ENT_DEBUG';
  G_PACKAGE_TOKEN          CONSTANT VARCHAR2(200) := 'Package';
  G_PROGRAM_TOKEN          CONSTANT VARCHAR2(200) := 'Program';
  G_PKG_NAME	           CONSTANT VARCHAR2(200) := 'OKS_COV_ENT_PUB';
  G_APP_NAME_OKS	       CONSTANT VARCHAR2(3)   := 'OKS';
  G_APP_NAME_OKC	       CONSTANT VARCHAR2(3)   := 'OKC';


PROCEDURE Get_default_react_resolve_by
    (p_api_version           in  number
    ,p_init_msg_list         in  varchar2
    ,p_inp_rec               in  gdrt_inp_rec_type
    ,x_return_status         out nocopy varchar2
    ,x_msg_count             out nocopy number
    ,x_msg_data              out nocopy varchar2
    ,x_react_rec             out nocopy rcn_rsn_rec_type
    ,x_resolve_rec           out nocopy rcn_rsn_rec_type);

END OKS_COV_ENT_PVT;


 

/
