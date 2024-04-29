--------------------------------------------------------
--  DDL for Package Body GMD_QC_SPEC_MATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_SPEC_MATCH" AS
/* $Header: GMDQMCHB.pls 115.11 2003/12/05 17:06:23 pupakare noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_QC_SPEC_MATCH';

/*======================================================================
--  FUNCTION :
--    FIND_CUST_SPEC
--
--===================================================================== */

FUNCTION find_cust_spec ( p_cust_spec     IN  find_cust_spec_rec)
                          RETURN cust_spec_out_tbl
IS
  /* Local variables.
  ==================*/
l_out_rec               cust_spec_out_tbl;  --BUG#2798878
l_out_record            cust_spec_out_rec;
BEGIN
    l_out_record.spec_hdr_id := 0;
    l_out_rec(1) := l_out_record;
    return l_out_rec;
exception
   when others then
       return l_out_rec;
END find_cust_spec;

/*======================================================================
--  PROCEDURE :
--    GET_SPEC_MATCH
--===================================================================== */

PROCEDURE get_spec_match
                  ( p_spec_hdr_id   IN  NUMBER
                   ,p_lots_in       IN  result_lot_match_tbl
                   ,p_api_version   In NUMBER
                   ,p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   ,p_results_out   OUT NOCOPY result_lot_match_tbl
                   ,p_return_status OUT NOCOPY VARCHAR2
                   ,P_msg_count     OUT NOCOPY NUMBER
                   ,P_msg_stack     OUT NOCOPY VARCHAR2
                  ) IS
BEGIN
p_return_status := FND_API.G_RET_STS_SUCCESS;     -- initialize

EXCEPTION
  WHEN OTHERS THEN
     P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
END get_spec_match;
END GMD_QC_SPEC_MATCH;

/
