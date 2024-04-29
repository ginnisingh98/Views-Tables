--------------------------------------------------------
--  DDL for Package BEN_CREATE_PTNL_LER_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CREATE_PTNL_LER_SS" AUTHID CURRENT_USER AS
/* $Header: belerwrs.pkh 115.4 2002/12/30 18:53:57 rpillay noship $*/

  gv_wf_review_region_item    constant wf_item_attributes.name%type
                             := 'HR_REVIEW_REGION_ITEM';

   --This is a overloaded procedure which will call the actual wrapper


    PROCEDURE create_ptnl_ler_for_per
    (p_validate                       in  varchar2  default 'N'
    ,p_ptnl_ler_for_per_id            out nocopy varchar2
    ,p_csd_by_ptnl_ler_for_per_id     in  varchar2  default null
    ,p_lf_evt_ocrd_dt                 in  out nocopy varchar2
    ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
    ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
    ,p_mnl_dt                         in  varchar2  default null
    ,p_enrt_perd_id                   in  varchar2  default null
    ,p_ler_id                         in  varchar2  default null
    ,p_person_id                      in  varchar2  default null
    ,p_business_group_id              in  varchar2  default null
    ,p_dtctd_dt                       in  varchar2  default null
    ,p_procd_dt                       in  varchar2  default null
    ,p_unprocd_dt                     in  varchar2  default null
    ,p_voidd_dt                       in  varchar2  default null
    ,p_mnlo_dt                        in  varchar2  default null
    ,p_ntfn_dt                        in  varchar2  default null
    ,p_request_id                     in  varchar2  default null
    ,p_program_application_id         in  varchar2  default null
    ,p_program_id                     in  varchar2  default null
    ,p_program_update_date            in  varchar2  default null
    ,p_object_version_number          out nocopy varchar2
    ,p_effective_date                 in  varchar2
    ,p_item_type                      in  varchar2
    ,p_item_key                       in  varchar2
    ,p_activity_id                    in  varchar2
    ,p_login_person_id                in  varchar2  default null
    ,P_flow_mode                      in  varchar2
    ,p_subflow_mode                   in  varchar2
    ,p_life_event_name                in  varchar2
    ,p_transaction_step_id            out nocopy varchar2
    ,p_error_message                  out nocopy long
    ,p_hire_dt                        in  varchar2  default null
);



  PROCEDURE create_ptnl_ler_for_per
    (p_validate                       in  varchar2  default 'N'
    ,p_ptnl_ler_for_per_id            out nocopy number
    ,p_csd_by_ptnl_ler_for_per_id     in  number    default null
    ,p_lf_evt_ocrd_dt                 in  date      default null
    ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
    ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
    ,p_mnl_dt                         in  date      default null
    ,p_enrt_perd_id                   in  number    default null
    ,p_ler_id                         in  number    default null
    ,p_person_id                      in  number    default null
    ,p_business_group_id              in  number    default null
    ,p_dtctd_dt                       in  date      default null
    ,p_procd_dt                       in  date      default null
    ,p_unprocd_dt                     in  date      default null
    ,p_voidd_dt                       in  date      default null
    ,p_mnlo_dt                        in  date      default null
    ,p_ntfn_dt                        in  date      default null
    ,p_request_id                     in  number    default null
    ,p_program_application_id         in  number    default null
    ,p_program_id                     in  number    default null
    ,p_program_update_date            in  date      default null
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_item_type                      in  varchar2
    ,p_item_key                       in  varchar2
    ,p_activity_id                    in  number
    ,p_login_person_id                in  number    default null
    ,P_flow_mode                      in  varchar2
    ,p_subflow_mode                   in  varchar2
    ,p_life_event_name                in  varchar2
    ,p_transaction_step_id            out nocopy number
    ,p_error_message                  out nocopy long
);


-- ---------------------------------------------------------------------------
-- ---------------------- < get_address_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
-- ---------------------------------------------------------------------------

PROCEDURE get_ptnl_ler_data_from_tt
   (p_transaction_step_id             in    number
   ,p_csd_by_ptnl_ler_for_per_id      out nocopy   number  -- in  number    default null
   ,p_lf_evt_ocrd_dt                  out nocopy   date  -- in  date      default null
   ,p_ptnl_ler_for_per_stat_cd        out nocopy   varchar2  -- in  varchar2  default null
   ,p_ptnl_ler_for_per_src_cd         out nocopy   varchar2  -- in  varchar2  default null
   ,p_mnl_dt                          out nocopy   date  -- in  date      default null
   ,p_enrt_perd_id                    out nocopy   number  -- in  number    default null
   ,p_ler_id                          out nocopy   number  -- in  number    default null
   ,p_person_id                       out nocopy   number  -- in  number    default null
   ,p_business_group_id               out nocopy   number  -- in  number    default null
   ,p_dtctd_dt                        out nocopy   date  -- in  date      default null
   ,p_procd_dt                        out nocopy   date  -- in  date      default null
   ,p_unprocd_dt                      out nocopy   date  -- in  date      default null
   ,p_voidd_dt                        out nocopy   date  -- in  date      default null
   ,p_mnlo_dt                         out nocopy   date  -- in  date      default null
   ,p_ntfn_dt                         out nocopy   date  -- in  date      default null
   ,p_request_id                      out nocopy   number -- in  number    default null
   ,p_program_application_id          out nocopy   number  -- in  number    default null
   ,p_program_id                      out nocopy   number  -- in  number    default null
   ,p_program_update_date             out nocopy   date  -- in  date      default null
   ,p_effective_date                  out nocopy   date
   ,p_flow_mode                       in   varchar2
   ,p_subflow_mode                    in   varchar2
   ,p_life_event_name                 out nocopy   varchar2
);

-- ---------------------------------------------------------------------------
-- ---------------------- < get_address_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_ptnl_ler_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_csd_by_ptnl_ler_for_per_id      out nocopy number    -- in  number    default null
   ,p_lf_evt_ocrd_dt                  out nocopy date      -- in  date      default null
   ,p_ptnl_ler_for_per_stat_cd        out nocopy varchar2  -- in  varchar2  default null
   ,p_ptnl_ler_for_per_src_cd         out nocopy varchar2  -- in  varchar2  default null
   ,p_mnl_dt                          out nocopy date      -- in  date      default null
   ,p_enrt_perd_id                    out nocopy number    -- in  number    default null
   ,p_ler_id                          out nocopy number    -- in  number    default null
   ,p_person_id                       out nocopy number    -- in  number    default null
   ,p_business_group_id               out nocopy number    -- in  number    default null
   ,p_dtctd_dt                        out nocopy date      -- in  date      default null
   ,p_procd_dt                        out nocopy date      -- in  date      default null
   ,p_unprocd_dt                      out nocopy date      -- in  date      default null
   ,p_voidd_dt                        out nocopy date      -- in  date      default null
   ,p_mnlo_dt                         out nocopy date      -- in  date      default null
   ,p_ntfn_dt                         out nocopy date      -- in  date      default null
   ,p_request_id                      out nocopy number    -- in  number    default null
   ,p_program_application_id          out nocopy number    -- in  number    default null
   ,p_program_id                      out nocopy number    -- in  number    default null
   ,p_program_update_date             out nocopy date      -- in  date      default null
   ,p_effective_date                  out nocopy date
   ,p_flow_mode                       in varchar2
   ,p_subflow_mode                    in varchar2
   ,p_life_event_name                 out nocopy varchar2
);


/*---------------------------------------------------------------------------+
|                                                                            |
|       Name           : process_api                                         |
|                                                                            |
|       Purpose        : This will procedure is invoked whenever approver    |
|                        approves the address change.                        |
|                                                                            |
+-----------------------------------------------------------------------------*/
PROCEDURE process_api
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
);

procedure get_step(
     p_item_type                in     varchar2
    ,p_item_key                 in     varchar2
    ,p_activity_id              in     varchar2
    ,p_api_name                 in     varchar2
    ,p_flow_mode                in     varchar2
    ,p_subflow_mode             in     varchar2
    ,p_transaction_step_id      out nocopy    number
    ,p_object_version_number    out nocopy    number );



END ben_create_ptnl_ler_ss;

 

/
