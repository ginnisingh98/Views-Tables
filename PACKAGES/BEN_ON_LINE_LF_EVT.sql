--------------------------------------------------------
--  DDL for Package BEN_ON_LINE_LF_EVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ON_LINE_LF_EVT" AUTHID CURRENT_USER AS
/* $Header: benollet.pkh 120.1 2005/09/28 03:15:32 ssarkar noship $ */
--
-- Global set bet by evaluate potentials module if
-- any potentials are set to VOID.
--
g_ptnls_voidd_flag     boolean := FALSE;
        --
  procedure Start_on_line_lf_evt_proc(p_person_id            in number,
                    p_effective_date       in date,
                    p_business_group_id    in number,
                    p_error_msg            in varchar2 ,
                    p_userkey              in varchar2,
                    p_itemkey              out nocopy varchar2
              );
        --
  procedure End_on_line_lf_evt_proc(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    result    in out nocopy varchar2  ) ;
        --
        -- Determine which process to run if a item_type have multiple
        -- runnable processes.
        -- itemtype  : a valid item type
        -- itemkey   : A string generated from application object's PK.
        -- actid     : The function activity ( instance id )
        -- funcmode  : Run/Cancel
        -- resultout : Name of the workflow process to run.
        --
  procedure Selector(itemtype in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out nocopy varchar2);
        --
        --
        -- Determine number of records for the person in life event reasons
        -- potential life event reasons.
        -- itemtype  : a valid item type
        -- itemkey   : A string generated from application object's PK.
        -- actid     : The function activity ( instance id )
        -- funcmode  : Run/Cancel
        -- resultout : Name of the workflow process to run.
        --
  procedure p_cnt_ple(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out nocopy varchar2);
        --
        -- Test whether it's possible to run the form from
        -- function avtivity.
        -- itemtype  : a valid item type
        -- itemkey   : A string generated from application object's PK.
        -- actid     : The function activity ( instance id )
        -- funcmode  : Run/Cancel
        -- resultout : Name of the workflow process to run.
        --
        procedure p_run_form(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2);
        --
        procedure p_evt_lf_events(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2);
        --
        procedure p_mng_lf_events(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2);
        --
        procedure p_have_elctbl_chcs(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2);
        --
        procedure p_can_prtcpnt_enrl(itemtype    in varchar2,
                    itemkey      in varchar2,
                    actid        in number,
                    funcmode     in varchar2,
                    resultout    out nocopy varchar2);
        --
        --
        -- procedure to evaluate the potential life events,
        -- and life events
        --
        procedure p_manage_life_events(
                    p_person_id             in   number
                   ,p_effective_date        in   date
                   ,p_business_group_id     in   number
                   ,p_prog_count            out nocopy  number
                   ,p_plan_count            out nocopy  number
                   ,p_oipl_count            out nocopy  number
                   ,p_person_count          out nocopy  number
                   ,p_plan_nip_count        out nocopy  number
                   ,p_oipl_nip_count        out nocopy  number
                   ,p_ler_id                out nocopy  number
                   ,p_errbuf                out nocopy  varchar2
                   ,p_retcode               out nocopy  number);
        --
        --
        --
        -- procedure to evaluate the potential life events,
        -- and life events
        --
        procedure p_manage_life_events(
                    p_person_id             in   number
                   ,p_effective_date        in   date
                   ,p_business_group_id     in   number
                   ,p_pgm_id                in   number default null
                   ,p_pl_id                 in   number default null
                   ,p_mode                  in   varchar2
                   ,p_lf_evt_ocrd_dt        in   date default null --GLOBAL CWB
                   ,p_prog_count            out nocopy  number
                   ,p_plan_count            out nocopy  number
                   ,p_oipl_count            out nocopy  number
                   ,p_person_count          out nocopy  number
                   ,p_plan_nip_count        out nocopy  number
                   ,p_oipl_nip_count        out nocopy  number
                   ,p_ler_id                out nocopy  number
                   ,p_errbuf                out nocopy  varchar2
                   ,p_retcode               out nocopy  number);
        --
        --
        -- procedure to evaluate the potential life events,
        -- and life events from benwatif as it passes the
        -- derivable factors flag. In future it may be possible to
        -- bypass the some of the benwatif steps
        --
        procedure p_watif_manage_life_events(
                    p_person_id             in   number
                   ,p_effective_date        in   date
                   ,p_business_group_id     in   number
                   ,p_pgm_id                in   number default null
                   ,p_pl_id                 in   number default null
                   ,p_mode                  in   varchar2
                   ,p_derivable_factors     in   varchar2
                   ,p_prog_count            out nocopy  number
                   ,p_plan_count            out nocopy  number
                   ,p_oipl_count            out nocopy  number
                   ,p_person_count          out nocopy  number
                   ,p_plan_nip_count        out nocopy  number
                   ,p_oipl_nip_count        out nocopy  number
                   ,p_ler_id                out nocopy  number
                   ,p_errbuf                out nocopy  varchar2
                   ,p_retcode               out nocopy  number);
        --
        -- procedure to check whether the context is already established.
        -- if established then authentication form is bypassed.
        --
        procedure p_context_def(
                    itemtype                in varchar2
                   ,itemkey                 in varchar2
                   ,actid                   in number
                   ,funcmode                in varchar2
                   ,resultout               out nocopy varchar2);
        --
        procedure p_commit;
        --
        --
        -- This procedure to evaluate the potential life events,
        -- and life events called from benauthe form as a CSR
        -- desktop activity.
        --
        procedure p_evt_lf_evts_from_benauthe(
          p_person_id             in   number
         ,p_effective_date        in   date
         ,p_business_group_id     in   number
         ,p_pgm_id                in   number default null
         ,p_pl_id                 in   number default null
         ,p_mode                  in   varchar2
         ,p_popl_enrt_typ_cycl_id in   number
         ,p_lf_evt_ocrd_dt        in   date
         ,p_prog_count            out nocopy  number
         ,p_plan_count            out nocopy  number
         ,p_oipl_count            out nocopy  number
         ,p_person_count          out nocopy  number
         ,p_plan_nip_count        out nocopy  number
         ,p_oipl_nip_count        out nocopy  number
         ,p_ler_id                out nocopy  number
         ,p_errbuf                out nocopy  varchar2
         ,p_retcode           out nocopy  number);
        --
        -- This procedure to process life events called from benauthe form
        -- as a CSR desktop activity.
        --
        procedure p_proc_lf_evts_from_benauthe(
          p_person_id             in   number
         ,p_effective_date        in   date
         ,p_business_group_id     in   number
         ,p_mode                  in   varchar2
         ,p_ler_id                in   number
          -- PB : 5422 :
          -- ,p_popl_enrt_typ_cycl_id in   number
         ,p_lf_evt_ocrd_dt        in   date default null
         ,p_person_count          out nocopy  number
         ,p_benefit_action_id     out nocopy  number
         ,p_errbuf                out nocopy  varchar2
         ,p_retcode           out nocopy  number);
        --
        procedure p_oll_pop_up_message
         (p_person_id             in     number
         ,p_business_group_id     in     number
         ,p_function_name         in     varchar2
         ,p_block_name            in     varchar2
         ,p_field_name            in     varchar2
         ,p_event_name            in     varchar2
         ,p_effective_date        in     date
         ,p_payroll_id            in number   default null
         ,p_payroll_action_id     in number   default null
         ,p_assignment_id         in number   default null
         ,p_assignment_action_id  in number   default null
         ,p_org_pay_method_id     in number   default null
         ,p_per_pay_method_id     in number   default null
         ,p_organization_id       in number   default null
         ,p_tax_unit_id           in number   default null
         ,p_jurisdiction_code     in number   default null
         ,p_balance_date          in number   default null
         ,p_element_entry_id      in number   default null
         ,p_element_type_id       in number   default null
         ,p_original_entry_id     in number   default null
         ,p_tax_group             in number   default null
         ,p_pgm_id                in number   default null
         ,p_pl_id                 in number   default null
         ,p_pl_typ_id             in number   default null
         ,p_opt_id                in number   default null
         ,p_ler_id                in number   default null
         ,p_communication_type_id in number   default null
         ,p_action_type_id        in number   default null
         ,p_message_count         out nocopy    number
         ,p_message1              out nocopy    varchar2
         ,p_message_type1         out nocopy    varchar2
         ,p_message2              out nocopy    varchar2
         ,p_message_type2         out nocopy    varchar2
         ,p_message3              out nocopy    varchar2
         ,p_message_type3         out nocopy    varchar2
         ,p_message4              out nocopy    varchar2
         ,p_message_type4         out nocopy    varchar2
         ,p_message5              out nocopy    varchar2
         ,p_message_type5         out nocopy    varchar2
         ,p_message6              out nocopy    varchar2
         ,p_message_type6         out nocopy    varchar2
         ,p_message7              out nocopy    varchar2
         ,p_message_type7         out nocopy    varchar2
         ,p_message8              out nocopy    varchar2
         ,p_message_type8         out nocopy    varchar2
         ,p_message9              out nocopy    varchar2
         ,p_message_type9         out nocopy    varchar2
         ,p_message10             out nocopy    varchar2
         ,p_message_type10        out nocopy    varchar2
         );
                 -- 99999 any other parameters like : pl_id ler_id etc., to
                 -- be used as parameters.
         --
         function f_ret_ptnls_voidd_flag return boolean;
         --
         -- Bug : 4504/1217193 This procedure is called from the form
         -- BENWFREP to see whether any electable choices are created by this
         -- run of benmngle. If not created then return a message.
         --
         function f_ret_elec_chc_created return boolean;
         --
         procedure get_ser_message(p_encoded_message out nocopy varchar2,
                                   p_app_short_name out nocopy varchar2,
                                   p_message_name out nocopy varchar2);

        --
        -- self-service wrapper to run benmngle in
        -- unrestricted mode.
        --
        procedure p_manage_life_events_w(
                    p_person_id             in   number
                   ,p_effective_date        in   date
                   ,p_lf_evt_ocrd_dt        in   date default null
                   ,p_business_group_id     in   number
                   ,p_mode                  in   varchar2
                   ,p_ss_process_unrestricted    in   varchar2 default 'Y'
		   ,p_return_status          out nocopy varchar2); --4254792
        --
        -- iRec : self-service wrapper to run benmngle through
        -- iRecruitment
        --
        procedure p_manage_irec_life_events_w(
                    p_person_id             in   number
                   ,p_assignment_id         in   number
        	   ,p_effective_date        in   date
                   ,p_business_group_id     in   number
		   ,p_offer_assignment_rec  in   per_all_assignments_f%rowtype); --bug 4621751 irec2
        --

end ben_on_line_lf_evt;

 

/
