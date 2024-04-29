--------------------------------------------------------
--  DDL for Package OKS_COV_ENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COV_ENT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPCENS.pls 120.1.12010000.2 2010/05/03 12:36:02 vgujarat ship $ */

-- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME	                   CONSTANT VARCHAR2(200) := 'OKS_COV_ENT_PUB';
  G_APP_NAME_OKS	               CONSTANT VARCHAR2(3)   :=  'OKS';
  G_APP_NAME_OKC	               CONSTANT VARCHAR2(3)   :=  'OKC';
  -------------------------------------------------------------------------------


  G_BEST                       CONSTANT VARCHAR2(10):= 'BEST';
  G_FIRST                      CONSTANT VARCHAR2(10):= 'FIRST';
  G_REACTION                   CONSTANT VARCHAR2(90) := 'RCN';
  G_RESOLUTION                 CONSTANT VARCHAR2(90) := 'RSN';
  G_REACT_RESOLVE              CONSTANT VARCHAR2(90) := 'RCN_RSN';

  G_REACTION_TIME              CONSTANT VARCHAR2(10):= 'RCN';
  G_RESOLUTION_TIME            CONSTANT VARCHAR2(10):= 'RSN';
  G_COVERAGE_TYPE_IMP_LEVEL    CONSTANT VARCHAR2(10):= 'COVTYP_IMP';
  G_NO_SORT_KEY                CONSTANT VARCHAR2(10):= 'NO_KEY';

  /**

    Procedure Specification:

      PROCEDURE Get_default_react_resolve_by
      (p_api_version                in  number
      ,p_init_msg_list              in  varchar2
      ,p_inp_rec                    in  gdrt_inp_rec_type
      ,x_return_status              out nocopy varchar2
      ,x_msg_count                  out nocopy number
      ,x_msg_data                   out nocopy varchar2
      ,x_react_rec                  out nocopy rcn_rsn_rec_type
      ,x_resolve_rec                out nocopy rcn_rsn_rec_type);

    Current Version:
        1.0

    Parameter Descriptions:

        The following table describes the IN parameters associated with this API.

        Parameter               Data Type           Required        Description and
                                                                    Validations

        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
        p_inp_rec               gdrt_inp_rec_type    Yes             See Below the Data Structure Specification: gdrt_inp_rec_type.


        Input Record Specification: gdrt_inp_rec_type

        Parameter               Data Type           Required        Description and Validations

        coverage_template_id    NUMBER              Yes             Coverage Template line ID.
        business_process_id     NUMBER              Yes             Business Process ID.
        request_date            DATE                No              Request Date. The default is system date.
        severity_id             NUMBER              Yes             Severity ID. service request severity id.
        time_zone_id            NUMBER              Yes             Request Time Zone ID.

        The following table describes the OUT parameters associated with this API:

        Parameter               Data Type           Description

        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
        x_react_rec             rcn_rsn_rec_type    Reaction Time information.
                                                        See the Data Structure Specification: rcn_rsn_rec_type
        x_resolve_rec           rcn_rsn_rec_type    Resolution Time information.
                                                        See the Data Structure Specification: rcn_rsn_rec_type.

        Output Record Specification: rcn_rsn_rec_type:

        Parameter               Data Type           Description

        by_date_start           DATE                Date and Time by which the Reaction
                                                        or Resolution has begun for a Service Request.
        by_date_end             DATE                Date and Time by which the Reaction
                                                        or Resolution has to be completed for a Service Request.

    Procedure Description:

        This API returns react by start and end times as x_react_rec
        and resolve by start and end times as x_resolv_rec for the given inputs.

        The API accepts input as a record type grt_inp_rec_type.

        The inputs accepted are
        contract_line_id,business_process_id,severity_id,request_date,time_zone_id,
        category_rcn_rsn,compute_option.

   */

/*vgujarat - modified for access hour ER 9675504*/
   TYPE gdrt_inp_rec_type     IS RECORD
    (Coverage_template_id         number
    ,Business_process_id          number
    ,request_date                 date
    ,Severity_id                  number
    ,Time_zone_id                 number
    ,Dates_In_Input_TZ            VARCHAR2(1) -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,cust_id                   NUMBER  DEFAULT null
    ,cust_site_id              NUMBER  DEFAULT null
    ,cust_loc_id               NUMBER  DEFAULT null);

  TYPE rcn_rsn_rec_type IS RECORD
    (by_date_start                date
    ,by_date_end                  date);

   PROCEDURE Get_default_react_resolve_by
    (p_api_version                in  number
    ,p_init_msg_list              in  varchar2
    ,p_inp_rec                    in  gdrt_inp_rec_type
    ,x_return_status              out nocopy varchar2
    ,x_msg_count                  out nocopy number
    ,x_msg_data                   out nocopy varchar2
    ,x_react_rec                  out nocopy rcn_rsn_rec_type
    ,x_resolve_rec                out nocopy rcn_rsn_rec_type);

END OKS_COV_ENT_PUB;

/
