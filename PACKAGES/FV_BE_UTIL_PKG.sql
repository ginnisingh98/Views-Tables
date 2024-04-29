--------------------------------------------------------
--  DDL for Package FV_BE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_BE_UTIL_PKG" AUTHID CURRENT_USER AS
--  $Header: FVBEUTLS.pls 120.4.12010000.2 2009/06/17 16:36:50 sharoy ship $    |

-- Added For Bug 7482804
FUNCTION has_segments_access(   p_bud_segments IN varchar2
                                ,p_ccid IN NUMBER
                                ,p_coa_id IN NUMBER
                                ,p_sob_id IN NUMBER) RETURN varchar2;


-- BCPSA-BE Enhancements
-- Removed p_transaction_code parameter
-- Added p_transaction_type_id and p_sub_type parameters
procedure check_cross_validation ( errbuf        OUT NOCOPY varchar2,
         retcode       OUT NOCOPY number,
	 p_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE,
	 p_header_segments fnd_flex_ext.SegmentArray,
	 p_detail_segments fnd_flex_ext.SegmentArray,
	 p_budget_level_id fv_be_trx_hdrs.budget_level_id%TYPE,
	 p_transaction_type_id fv_be_trx_dtls.transaction_type_id%TYPE,
	 p_sub_type fv_be_trx_dtls.sub_type%TYPE,
	 p_source           fv_be_trx_hdrs.source%TYPE,
	 p_increase_decrease_flag fv_be_trx_dtls.increase_decrease_flag%TYPE);

procedure initialize_gl_segments(p_from_segments IN fnd_flex_ext.SegmentArray,
				 p_to_segments   OUT NOCOPY fnd_flex_ext.SegmentArray) ;

end fv_be_util_pkg; -- Package spec

/
