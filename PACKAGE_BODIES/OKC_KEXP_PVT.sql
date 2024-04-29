--------------------------------------------------------
--  DDL for Package Body OKC_KEXP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_KEXP_PVT" AS
/* $Header: OKCRKEXB.pls 120.0 2005/05/25 23:03:56 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE load_ksrch_rows
          ( p_ksearch_where_clause IN  VARCHAR2,
            x_return_status 	  OUT NOCOPY VARCHAR2,
            x_report_id     	  OUT NOCOPY NUMBER   )
IS
  -- Collection table definition
     TYPE                  okc_kexp_report_tbl_type IS
					  TABLE OF ROWID INDEX BY BINARY_INTEGER;
     okc_kexp_pls_tbl      okc_kexp_report_tbl_type;

  -- Ref Cursor to concatenate with the where clause from KSEARCH form.
     TYPE             okc_kexp_cur_type IS REF CURSOR;
     okc_kexp_cur     okc_kexp_cur_type;

  l_block_size     NUMBER          := 1000;
  l_return_status  VARCHAR2(1)     := OKC_API.G_RET_STS_SUCCESS;
  l_qry            VARCHAR2(2000);
  l_index          NUMBER;
  l_rowid          ROWID;
  l_report_seq     NUMBER          := 0;

BEGIN

  -- -------------------------------------------------------------------
  -- Assign Sequence number for this search criteria based call.
  -- -------------------------------------------------------------------
     SELECT  okc_kexp_report_s1.NEXTVAL
	INTO    l_report_seq
	FROM    dual;

  -- --------------------------------------------------------------------
  -- Cursor to populate Temp_Table with Contract Header Row_Ids.
  -- Concatenates the ksearch Where-Clause of the Contract Search form.
  -- These Row_Ids are the source for the Full-view
  -- The Full-view is registered with one of the Discoverer Folders.
  -- The where-clause default value is set in the package specification.
  -- --------------------------------------------------------------------
     l_qry := 'SELECT row_id                '||
              'FROM   okc_k_headers_v  CHRV '||
              'WHERE                        '||
               p_ksearch_where_clause;                  --> Input Parameter

    -- -----------------------------------------------------------------
    -- Contract Search Cursor loop begin...
    -- -----------------------------------------------------------------
    l_index := 1;
    OPEN okc_kexp_cur FOR l_qry;
    LOOP
      -- ---------------------------------------------------------------
      -- Load the Temp Table with the current Ksearch where clause into
      -- a local PL/SQL table via loop Fetch, As Bulk-Fetch is not
      -- working with the Ref-Cursor defined above.
      -- ------------------------------------------------------------
  	    FETCH  okc_kexp_cur INTO l_rowid;

	    EXIT   WHEN okc_kexp_cur%NOTFOUND;

	    okc_kexp_pls_tbl(l_index) := l_rowid;

	    l_index := l_index + 1;

         IF okc_kexp_pls_tbl.COUNT = 0 THEN
	    	   EXIT;
         END IF;

      -- ------------------------------------------------------
      -- Bulk Insert into Temp Table
      -- ------------------------------------------------------
         FORALL i IN okc_kexp_pls_tbl.FIRST .. okc_kexp_pls_tbl.LAST
	    INSERT
	    INTO   OKC_KEXP_REPORT
	           (
	             CONTRACT_HEADER_ROWID,
	             REPORT_ID,
	             REPORT_DATE    )
            VALUES
			 (
                  okc_kexp_pls_tbl(i),        -- Row Id
                  l_report_seq,               -- Report Id
                  SYSDATE                     -- Report Date
                 );

	    COMMIT;

      -- -------------------------------------
	 -- Delete plsql collection table
	 -- -------------------------------------
	    okc_kexp_pls_tbl.DELETE;

      -- Physical temp table cleanup process to be defined later.

  END LOOP;

  -- --------------------------------------------------
  -- Prepare out parameters for sucessful completion.
  -- --------------------------------------------------
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     x_report_id     := l_report_seq;

EXCEPTION
    WHEN OTHERS THEN
       -- --------------------------------------------------
       -- Store SQL error message on message stack
       -- --------------------------------------------------
          OKC_API.set_message(p_app_name         => G_APP_NAME,
                              p_msg_name         => G_UNEXPECTED_ERROR,
                              p_token1           => G_SQLCODE_TOKEN,
                              p_token1_value     => SQLCODE,
                              p_token2           => G_SQLERRM_TOKEN,
                              p_token2_value     => SQLERRM);

      -- ------------------------------------------
      -- Return error status to the caller.
      -- Notify caller of an error as UNEXPETED error
      -- ------------------------------------------
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END  load_ksrch_rows;


PROCEDURE delete_ksrch_rows(
             p_from_date      IN  DATE     ,
             p_to_date        IN  DATE     ,
             x_return_status  OUT NOCOPY VARCHAR2 ) IS
BEGIN

   -- ------------------------------------------------------
   -- To delete rows from the temporary table for a given
   -- period of days. This procedure will be registered as
   -- the concurrent program, with two input parameters.
   -- ------------------------------------------------------
   IF   p_from_date <= p_to_date
   THEN

        DELETE FROM okc_kexp_report
        WHERE       report_date
        BETWEEN     p_from_date AND p_to_date;

     -- --------------------------------------------------
     -- Prepare out parameters for sucessful completion.
     -- --------------------------------------------------
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        COMMIT;

    ELSE
     -- --------------------------------------------------
     -- Return error status to the caller.
     -- --------------------------------------------------
        x_return_status := OKC_API.G_RET_STS_ERROR;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
       -- --------------------------------------------------
       -- Store SQL error message on message stack
       -- --------------------------------------------------
          OKC_API.set_message(p_app_name         => G_APP_NAME,
                              p_msg_name         => G_UNEXPECTED_ERROR,
                              p_token1           => G_SQLCODE_TOKEN,
                              p_token1_value     => SQLCODE,
                              p_token2           => G_SQLERRM_TOKEN,
                              p_token2_value     => SQLERRM);

      -- ------------------------------------------
      -- Return error status to the caller.
      -- Notify caller of an error as UNEXPETED error
      -- ------------------------------------------
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END delete_ksrch_rows;

FUNCTION get_salesrep_name ( p_id1  IN  VARCHAR2,
                             p_id2  IN  VARCHAR2  )
RETURN VARCHAR2 IS
	l_name	VARCHAR2(255);
	l_not_found BOOLEAN;

  -- --------------------------------------------------
  -- Cursor to query the OKX table given the two IDs.
  -- --------------------------------------------------
     CURSOR contact_cur IS
     SELECT name
     FROM   OKX_SALESREPS_V
	WHERE  id1 = p_id1
	AND    id2 = p_id2;

BEGIN
  -- --------------------------------------------------
  -- Fetch Sales Person Name from the OKX table.
  -- --------------------------------------------------
	OPEN  contact_cur;
	FETCH contact_cur INTO l_name;
	l_not_found := contact_cur%NOTFOUND;
	CLOSE contact_cur;

	IF (l_not_found) THEN
	   RETURN NULL;
	End if;

	RETURN l_name;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- --------------------------------------------------
    -- Close the cursor and return null.
    -- --------------------------------------------------
	  IF (contact_cur%ISOPEN) THEN
		CLOSE contact_cur;
	  END IF;
	  RETURN NULL;
END get_salesrep_name;

END okc_kexp_pvt;

/
