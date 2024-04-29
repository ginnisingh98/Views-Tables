--------------------------------------------------------
--  DDL for Package FND_FLEX_SERVER2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_SERVER2" AUTHID CURRENT_USER AS
/* $Header: AFFFSV2S.pls 120.1.12010000.6 2017/01/13 16:21:23 hgeorgi ship $ */


/* -------------------------------------------------------------------- */
/*    		          Private definitions                       	*/
/* -------------------------------------------------------------------- */

  file_print_rpt   utl_file.file_type;

  FUNCTION cross_validate(nsegs	  IN NUMBER,
			  segs	  IN FND_FLEX_SERVER1.ValueArray,
	 		  segfmt  IN FND_FLEX_SERVER1.SegFormats,
			  vdt     IN DATE,
    			  fstruct IN FND_FLEX_SERVER1.FlexStructId,
			  errcol  OUT nocopy VARCHAR2)	 RETURN NUMBER;

  /* Bug 21612876, This is a copy of cross_validate() function but added more
     parameters for more specific processing for the CVR report. */
  FUNCTION cross_validate_segs_report (nsegs	  IN NUMBER,
			               segs	  IN FND_FLEX_SERVER1.ValueArray,
               	 		       segfmt     IN FND_FLEX_SERVER1.SegFormats,
	             		       vdt        IN DATE,
    		             	       fstruct    IN FND_FLEX_SERVER1.FlexStructId,
                                       cvr_low    IN VARCHAR2,
                                       cvr_high   IN VARCHAR2,
             			       cvrmsg     OUT nocopy VARCHAR2)	 RETURN NUMBER;

  FUNCTION x_drop_cached_cv_result(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
				   n_segs    IN  NUMBER,
				   segs	   IN FND_FLEX_SERVER1.ValueArray)
    RETURN BOOLEAN;

  PROCEDURE x_clear_cv_cache;

/* Updated the signature of the function with the new parameters added for ER#2335710*/
PROCEDURE submit_rxr_report(errbuf            OUT nocopy VARCHAR2,
                            retcode           OUT nocopy VARCHAR2,
                            p_application_id  IN VARCHAR2,
                            p_id_flex_code    IN VARCHAR2,
                            p_id_flex_num     IN VARCHAR2,
                            p_show_non_sum_comb IN VARCHAR2 DEFAULT 'Y',
                            p_dis_non_sum_comb IN VARCHAR2,
                            p_show_sum_comb   IN VARCHAR2 DEFAULT 'N',
                            p_dis_sum_comb    IN VARCHAR2 DEFAULT 'N',
                            p_enddate_flag    IN VARCHAR2 DEFAULT NULL,
                            p_cvr_name_low    IN VARCHAR2 DEFAULT NULL,
                            p_cvr_name_high   IN VARCHAR2 DEFAULT NULL,
                            p_num_workers     IN NUMBER,
                            p_debug_flag      IN VARCHAR2);


  FUNCTION get_keystruct(appl_sname   IN  VARCHAR2,
			 flex_code    IN  VARCHAR2,
			 select_comb_from_view IN VARCHAR2,
			 flex_num     IN  NUMBER,
			 flex_struct  OUT nocopy FND_FLEX_SERVER1.FlexStructId,
    			 struct_info  OUT nocopy FND_FLEX_SERVER1.FlexStructInfo,
    			 cctbl_info   OUT nocopy FND_FLEX_SERVER1.CombTblInfo)
								RETURN BOOLEAN;
  FUNCTION get_descstruct(flex_app_sname  IN  VARCHAR2,
			  desc_flex_name  IN  VARCHAR2,
			  dfinfo 	  OUT nocopy FND_FLEX_SERVER1.DescFlexInfo)
							        RETURN BOOLEAN;

  FUNCTION get_struct_cols(fstruct      IN  FND_FLEX_SERVER1.FlexStructId,
			   table_apid   IN  NUMBER,
			   table_id     IN  NUMBER,
 			   n_columns    OUT nocopy NUMBER,
    			   cols         OUT nocopy FND_FLEX_SERVER1.TabColArray,
			   coltypes     OUT nocopy FND_FLEX_SERVER1.CharArray,
			   seg_formats  OUT nocopy FND_FLEX_SERVER1.SegFormats)
							        RETURN BOOLEAN;

  FUNCTION get_all_segquals(fstruct   IN  FND_FLEX_SERVER1.FlexStructId,
			    seg_quals OUT nocopy FND_FLEX_SERVER1.Qualifiers)
							   RETURN BOOLEAN;

  FUNCTION get_qualsegs(fstruct    IN  FND_FLEX_SERVER1.FlexStructId,
		        nsegs      OUT nocopy NUMBER,
			segdisp	   OUT nocopy FND_FLEX_SERVER1.CharArray,
			segrqd	   OUT nocopy FND_FLEX_SERVER1.CharArray,
			fqtab	   OUT nocopy FND_FLEX_SERVER1.FlexQualTable)
								RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/*	This should be moved back to key validation engine when there      */
/*	is room for it.							   */
/* ----------------------------------------------------------------------- */

  FUNCTION breakup_catsegs(catsegs        IN  VARCHAR2,
			   delim          IN  VARCHAR2,
			   vals_not_ids   IN  BOOLEAN,
			   displayed_segs IN  FND_FLEX_SERVER1.DisplayedSegs,
			   nsegs_out      OUT nocopy NUMBER,
			   segs_out	  IN OUT nocopy FND_FLEX_SERVER1.StringArray)
								RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/* Bug 21612876, This procedure is called from C code fdfgcx.lc            */
/* This procedure processes the CVR report. This procedure has better      */
/* performance than the original C validation api fdfvxr().                */
/* ----------------------------------------------------------------------- */
  PROCEDURE cross_validate_report(
                          appid	            IN NUMBER,
                          code              IN VARCHAR2,
                          structid          IN NUMBER,
			  concat_segs	    IN VARCHAR2,
	 		  concat_vs_format  IN VARCHAR2,
	 		  concat_vs_maxsize IN VARCHAR2,
	 		  delim             IN VARCHAR2,
                          nsegments         IN NUMBER,
                          cvr_low           IN VARCHAR2,
                          cvr_high          IN VARCHAR2,
                          vdate             IN VARCHAR2,
                          errcode           OUT nocopy NUMBER,
                          cvrmsg            OUT nocopy VARCHAR2);


  PROCEDURE cvr_report(errbuf            OUT nocopy VARCHAR2,
                       retcode           OUT nocopy VARCHAR2,
                       appid             IN NUMBER,
                       code              IN VARCHAR2,
                       structid          IN NUMBER,
                       nonsummary        IN VARCHAR2,
                       disnonsummary     IN VARCHAR2, -- Y or N if Y then update
                       summary           IN VARCHAR2,
                       dissummary        IN VARCHAR2,
                       enddate           IN VARCHAR2,
                       cvr_low           IN VARCHAR2,
                       cvr_high          IN VARCHAR2,
                       vdate             IN VARCHAR2,
                       minccid           IN NUMBER,
                       maxccid           IN NUMBER);

  PROCEDURE     cvr_report_segs(appid         IN NUMBER,
                               code          IN VARCHAR2,
                               structid      IN NUMBER,
                               nonsummary    IN VARCHAR2,
                               disnonsummary IN VARCHAR2, -- Y or N if Y then update
                               summary       IN VARCHAR2,
                               dissummary    IN VARCHAR2,
                               enddate       IN VARCHAR2,
                               cvr_low       IN VARCHAR2,
                               cvr_high      IN VARCHAR2,
                               vdate         IN VARCHAR2,
                               minccid       IN NUMBER,
                               maxccid       IN NUMBER,
                               errbuf        OUT nocopy VARCHAR2,
                               retcode       OUT nocopy VARCHAR2);

PROCEDURE submit_cvr_report(p_errbuf            OUT nocopy VARCHAR2,
                            p_retcode           OUT nocopy VARCHAR2,
                            p_appid             IN NUMBER,
                            p_code              IN VARCHAR2,
                            p_structid          IN NUMBER,
                            p_nonsummary        IN VARCHAR2,
                            p_disnonsummary     IN VARCHAR2,
                            p_summary           IN VARCHAR2,
                            p_dissummary        IN VARCHAR2,
                            p_enddate           IN VARCHAR2,
                            p_cvr_low           IN VARCHAR2,
                            p_cvr_high          IN VARCHAR2,
                            p_num_workers       IN NUMBER);

PROCEDURE cvr_report_parallel(p_application_id  IN NUMBER,
                              p_id_flex_code      IN VARCHAR2,
                              p_id_flex_num       IN NUMBER,
                              p_show_non_sum_comb IN VARCHAR2 DEFAULT 'Y',
                              p_dis_non_sum_comb  IN VARCHAR2 DEFAULT 'N',
                              p_show_sum_comb     IN VARCHAR2 DEFAULT 'Y',
                              p_dis_sum_comb      IN VARCHAR2 DEFAULT 'N',
                              p_enddate_flag      IN VARCHAR2 DEFAULT NULL,
                              p_cvr_name_low      IN VARCHAR2 DEFAULT NULL,
                              p_cvr_name_high     IN VARCHAR2 DEFAULT NULL,
                              p_num_workers       IN NUMBER,
                              p_errbuf            OUT nocopy VARCHAR2,
                              p_retcode           OUT nocopy VARCHAR2);


  PROCEDURE ol(vbuff  VARCHAR2, -- Buffer
               vright PLS_INTEGER DEFAULT 135, -- Optional Right-Margin size
               LEVEL  PLS_INTEGER DEFAULT 0 -- Optional Left-Margin size
               );

  PROCEDURE printl(vbuff   VARCHAR2);

  PROCEDURE cp_debug(p_debug IN VARCHAR2);


END fnd_flex_server2;

/
