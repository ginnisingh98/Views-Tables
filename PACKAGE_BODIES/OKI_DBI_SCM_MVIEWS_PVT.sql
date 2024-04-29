--------------------------------------------------------
--  DDL for Package Body OKI_DBI_SCM_MVIEWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_SCM_MVIEWS_PVT" AS
/* $Header: OKIRIMRB.pls 115.8 2003/04/29 23:56:41 rpotnuru noship $ */

  PROCEDURE refresh_scm
  (  errbuf    OUT NOCOPY VARCHAR2
   , retcode   OUT NOCOPY VARCHAR2
  ) IS

  line              VARCHAR2(4) := 1 ;
  l_parallel_degree NUMBER      := 0 ;

  BEGIN

    errbuf  := NULL ;
    retcode := 0 ;

    -- Fast refresh all the MVs related to the Service Contracts Management
    -- DBI Rack if possible else do a complete refresh.

    l_parallel_degree := bis_common_parameters.GET_DEGREE_OF_PARALLELISM() ;
    IF (l_parallel_degree = 1) THEN
      l_parallel_degree := 0 ;
    END IF ;

    bis_collection_utilities.put_line('The degree of parallelism is ' ||
                                       l_parallel_degree ) ;

    line:='5' ;
    oki_dbi_mv_util_pvt.refresh(  p_mv_name => 'oki_scm_01_j_mv'
                                , p_parallel_degree => l_parallel_degree ) ;
    bis_collection_utilities.put_line('MV: oki_scm_01_j_mv refreshed.') ;

    line:='10' ;
    oki_dbi_mv_util_pvt.refresh(  p_mv_name => 'oki_scm_ocr_mv'
                                , p_parallel_degree => l_parallel_degree ) ;
    bis_collection_utilities.put_line('MV: oki_scm_ocr_mv refreshed.') ;

    line:='15' ;
    oki_dbi_mv_util_pvt.refresh(  p_mv_name => 'oki_scm_o_1_mv'
                                , p_parallel_degree => l_parallel_degree ) ;
    bis_collection_utilities.put_line('MV: oki_scm_o_1_mv refreshed.') ;

    line:='20' ;
    oki_dbi_mv_util_pvt.refresh(  p_mv_name => 'oki_scm_o_2_mv'
                                , p_parallel_degree => l_parallel_degree ) ;
    bis_collection_utilities.put_line('MV: oki_scm_o_2_mv refreshed.') ;

    line:='25' ;
    oki_dbi_mv_util_pvt.refresh(  p_mv_name => 'oki_scm_ot_mv'
                                , p_parallel_degree => l_parallel_degree ) ;
    bis_collection_utilities.put_line('MV: oki_scm_ot_mv refreshed.') ;

    line:='30' ;
    oki_dbi_mv_util_pvt.refresh(  p_mv_name => 'oki_scm_blg_mv'
                                , p_parallel_degree => l_parallel_degree ) ;
    bis_collection_utilities.put_line('MV: oki_scm_blg_mv refreshed.') ;

    bis_collection_utilities.put_line('MV refresh completed successfully.') ;

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       RAISE;
    WHEN OTHERS THEN
      errbuf  := sqlerrm ;
      retcode := sqlcode ;
      bis_collection_utilities.put_line(errbuf || '' || retcode ) ;
      fnd_message.set_name(  application => 'FND'
                         , name          => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(  token => 'ROUTINE'
                          , value   => 'OKI_DBI_SCM_MVIEWS_PVT.refresh_scm ' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END refresh_scm ;

END oki_dbi_scm_mviews_pvt ;

/
