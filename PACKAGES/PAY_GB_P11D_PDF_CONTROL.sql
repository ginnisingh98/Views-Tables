--------------------------------------------------------
--  DDL for Package PAY_GB_P11D_PDF_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P11D_PDF_CONTROL" AUTHID CURRENT_USER AS
/* $Header: pygbp11dr.pkh 120.2.12010000.3 2009/10/07 07:34:18 namgoyal ship $ */
    PROCEDURE print_pdf(errbuf                out NOCOPY VARCHAR2,
                        retcode               out NOCOPY NUMBER,
                        p_print_address_page   in varchar2 default null,
                        p_print_p11d           in varchar2,
                        p_print_p11d_summary   in varchar2,
                        p_print_ws             in varchar2,
                        p_payroll_action_id    in varchar2,
                        p_organization_id      in varchar2 default null,
                        p_org_hierarchy        in varchar2 default null,
                        p_assignment_set_id    in varchar2 default null,
                        p_location_code        in varchar2 default null,
                        p_assignment_action_id in varchar2 default null,
                        p_business_group_id    in varchar2,
                        p_sort_order1          in varchar2 default null,
                        p_sort_order2          in varchar2 default null,
                        p_profile_out_folder   in varchar2 default null,
			p_rec_per_file         in varchar2,
                        p_chunk_size           in number,
                        p_person_type          in varchar2 default null,
			p_print_style          in varchar2 default null,--bug 8241399
			-- p_print style parameter added to suppress additional blank page
                        p_priv_mark             in varchar2 default null);--bug 8942337

END PAY_GB_P11D_PDF_CONTROL;

/
