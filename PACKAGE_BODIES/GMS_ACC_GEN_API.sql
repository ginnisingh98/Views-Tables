--------------------------------------------------------
--  DDL for Package Body GMS_ACC_GEN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_ACC_GEN_API" as
/* $Header: gmsacgnb.pls 120.2 2007/02/06 09:47:27 rshaik ship $ */


-- ================================================================
-- Get award_id for Expenditures OR encumbrance items.
-- ================================================================
FUNCTION GET_AWARD_ID (x_exp_item_id 	in NUMBER
					   ,x_doc_type		IN VARCHAR2
                       ,x_cdl_line_num 	in NUMBER
                       ,x_err_code      out NOCOPY NUMBER
                       ,x_err_msg       out NOCOPY varchar2)
return NUMBER is

	x_award_id		NUMBER ;


	CURSOR C_exp_award is
	SELECT award_id
      FROM gms_award_distributions
	 WHERE document_type = x_doc_type
	   and expenditure_item_id = x_exp_item_id
	   and nvl(cdl_line_num,1) = NVL(x_cdl_line_num,1)
	   and ADL_STATUS		   = 'A'  ;

BEGIN
    x_err_code := 0;
    x_err_msg := '';
	x_award_id := 0 ;

	IF x_doc_type not in ( 'EXP', 'ENC' ) THEN
		x_err_code := 1 ;
		x_err_msg  := 'DOC_TYPE_NOT_EXP_ENC' ;
		return 0 ;
	END IF ;

	open C_exp_award ;

	fetch C_exp_award into x_award_id ;

	IF C_exp_award%NOTFOUND THEN
		x_award_id := -1 ;
		x_err_code := 1 ;
		x_err_msg  := 'NO_DATA_FOUND' ;
	END IF ;

	close C_exp_award ;

	IF x_award_id = -1 THEN
		x_award_id := 0 ;
	END IF ;

	return x_award_id ;

EXCEPTION
	When OTHERS THEN
        x_err_code := 1;

		IF x_err_msg = '' THEN
        	x_err_msg := 'WHEN-OTHERS-EXCEPTION';
		END IF ;

		IF C_exp_award%ISOPEN THEN
			CLOSE C_exp_award ;
		END IF ;

        app_exception.raise_exception;
END get_award_id ;


-- ============================================================
-- Get award_id for passed award_set_id or Default award_id
-- depending on award_distribution is enabled
-- ============================================================
FUNCTION GET_AWARD_ID (x_award_set_id in NUMBER
                        ,x_attr_award_id in VARCHAR2
                        ,x_document_type in VARCHAR2
                        ,x_err_code out NOCOPY NUMBER
                        ,x_err_msg out NOCOPY varchar2)
return NUMBER is

-- Bug 2930402 fix : The cursor below is not required.
cursor get_award_id_w_doc_type (p_award_set_id in NUMBER, p_document_type in varchar2) is
    select  award_id
    from    gms_award_distributions
    where   award_set_id = p_award_set_id
    and     document_type = p_document_type
    and     adl_status = 'A'
    and     adl_line_num = 1;

cursor get_award_id_wo_doc_type (p_award_set_id in NUMBER) is
    select  award_id
    from    gms_award_distributions
    where   award_set_id = p_award_set_id
--    and     adl_status = 'A' -- Bug 2930402 fix.
    and     adl_line_num = 1;

cursor get_default_dist_award_id is
    select  default_dist_award_id
    from    gms_implementations;

l_award_id NUMBER;
x_default_dist_award_id NUMBER;

BEGIN
    x_err_code := 0;
    x_err_msg := '';

    -- if the first 8 characters of p_attr_award_id is 'SSP-GMS:' then
    -- anything that follows is the award_id and is coming from SSP.

    open get_default_dist_award_id;
    fetch get_default_dist_award_id into x_default_dist_award_id;
    close get_default_dist_award_id;

    if x_award_set_id = x_default_dist_award_id THEN
       return x_award_set_id ;
    end if;

/* Bug 2930402 fix..following is not required.

    if substr(x_attr_award_id,1,8) = 'SSP-GMS:' then
        return substr(x_attr_award_id,9);
    end if;

*/

    if x_award_set_id is NULL then
        x_err_code := 1;
        x_err_msg := 'GMS_SSP_AWARD_SET_ID_NULL';
        app_exception.raise_exception;
    end if;

        open get_award_id_wo_doc_type (x_award_set_id);
        fetch get_award_id_wo_doc_type into l_award_id;

		IF get_award_id_wo_doc_type%NOTFOUND THEN
	   		raise NO_DATA_FOUND ;
		END IF ;

        close get_award_id_wo_doc_type;

    return l_award_id;

/* Bug 2930402 fix. The following is not required.

    if nvl(x_document_type, 'REQ') not in ('REQ','PO','AP','APD','ENC','OPI') then
        x_err_code := 1;
        x_err_msg := 'GMS_SSP_INVALID_DOC_TYPE';
        app_exception.raise_exception;
    end if;

    if x_document_type is NULL then
        open get_award_id_wo_doc_type (x_award_set_id);
        fetch get_award_id_wo_doc_type into l_award_id;

		IF get_award_id_wo_doc_type%NOTFOUND THEN
	   		raise NO_DATA_FOUND ;
		END IF ;

        close get_award_id_wo_doc_type;
    else
		--x_document_type in ('REQ','PO','AP','APD','ENC','OPI') then
        open get_award_id_w_doc_type (x_award_set_id, x_document_type);
        fetch get_award_id_w_doc_type into l_award_id;

		IF get_award_id_w_doc_type%NOTFOUND THEN
	   		raise NO_DATA_FOUND ;
		END IF ;

        close get_award_id_w_doc_type;
    end if;

-- Bug 2930402 fix. */

EXCEPTION
    when OTHERS then

	IF get_award_id_w_doc_type%ISOPEN THEN
	   CLOSE get_award_id_w_doc_type ;
	END IF ;

	IF get_award_id_wo_doc_type%ISOPEN THEN
	   CLOSE get_award_id_wo_doc_type ;
	END IF ;

	IF get_default_dist_award_id%ISOPEN THEN
	   CLOSE get_default_dist_award_id;
	END IF ;


        x_err_code := 1;

		IF x_err_msg = '' THEN
           x_err_msg := 'GMS_SSP_AWARD_SET_ID_NULL';
		END IF ;

        app_exception.raise_exception;

END GET_AWARD_ID;
---------------------------------------------------------------------


-- ==================================================================
-- GET_AWARD_ID defined for workflow and account generator.
-- ==================================================================
FUNCTION GET_AWARD_ID (itemtype		IN  VARCHAR2
                       , itemkey  		IN  VARCHAR2
                       , actid			IN	NUMBER
                       , funcmode		IN  VARCHAR2
                       , resultout		OUT NOCOPY	VARCHAR2,
						p_doc_type		IN   VARCHAR2  )

return NUMBER
IS

l_award_set_id 		NUMBER;
l_attr_award_id 	VARCHAR2(30);
l_award_id 			NUMBER;
l_err_code 			NUMBER;
l_err_msg 			VARCHAR2(2000);
l_doc_type			varchar2(3) ;

CURSOR GET_DOC_TYPE (p_award_set_id in NUMBER) is
    select  document_type
    from    gms_award_distributions
    where   award_set_id = p_award_set_id
    and     adl_status = 'A'
    and     adl_line_num = 1;

BEGIN

  if (funcmode <> wf_engine.eng_run) then
      resultout := 'ERROR';
      RETURN 0;
  end if;

    l_award_set_id := wf_engine.GetItemAttrNumber( 	itemtype  	=> itemtype,
			    				                    itemkey   	=> itemkey,
			    				                    aname  		=> 'AWARD_SET_ID' );


    IF l_award_set_id is not NULL AND
	   l_award_set_id > 0 		  THEN
	   open get_doc_type (l_award_set_id) ;
	   FETCH get_doc_type into l_doc_type ;

	   IF get_doc_type%NOTFOUND THEN
		  raise NO_DATA_FOUND ;
  	   END IF ;

	   CLOSE get_doc_type ;

	END IF ;

	IF NVL(l_doc_type,P_DOC_TYPE) IN ( 'REQ' ) THEN

			l_attr_award_id := wf_engine.GetItemAttrText( itemtype  	=> itemtype,
															itemkey   	=> itemkey,
															aname  		=> 'LINE_ATT7' );

	END IF ;


    l_award_id := get_award_id (x_award_set_id => l_award_set_id,
                                x_attr_award_id => l_attr_award_id,
                                x_document_type => l_doc_type,
                                x_err_code => l_err_code,
                                x_err_msg => l_err_msg);

   if l_err_code <> 0 then
        resultout := 'COMPLETE:FAILURE';
    end if;

	resultout	:= 'COMPLETE:SUCCESS' ;

   return l_award_id;

EXCEPTION
	WHEN OTHERS THEN
        resultout := 'COMPLETE:FAILURE';

		IF get_doc_type%ISOPEN THEN
			close get_doc_type ;
		END IF ;

		RAISE ;
END GET_AWARD_ID;


-- ===================================================
-- BUG : 1703224 GENERIC API TO GET AWARD FROM ADL.
-- ===================================================

FUNCTION GET_AWARD_ID ( x_award_set_id  IN NUMBER,
						x_doc_type      IN varchar2
					   ) return NUMBER IS
	x_award_id	NUMBER ;
BEGIN

	IF x_award_set_id is NULL THEN
		return NULL ;
	END IF ;

	IF NVL(x_doc_type,'X') in ( 'PO','REQ','AP' ) THEN

		SELECT award_id
		  INTO x_award_id
		  FROM gms_award_distributions
		 WHERE award_set_id	= x_award_set_id
		   and document_type	= x_doc_type
		   and adl_status		= 'A'
		   and adl_line_num		= 1 ;

	END IF ;

	return x_award_id ;

END GET_AWARD_ID  ;

-- ===================================================
-- BUG : 1703224 GENERIC API TO GET AWARD FROM ADL.
-- ===================================================
FUNCTION GET_AWARD_ID ( x_exp_enc_item_id  	IN NUMBER,
						x_doc_type      	IN varchar2,
						x_cdl_line			IN NUMBER
					   ) return NUMBER IS
	x_award_id	NUMBER ;
BEGIN

	IF x_exp_enc_item_id is NULL THEN
		return NULL ;
	END IF ;

	IF NVL(x_doc_type,'X') in ( 'EXP' , 'ENC' ) THEN

		SELECT award_id
		  INTO x_award_id
		  FROM gms_award_distributions
		 WHERE expenditure_item_id	= NVL( x_exp_enc_item_id, 0)
		   AND nvl(cdl_line_num, 1)		= NVL(x_cdl_line,1) --Bug 5726575
		   AND document_type		= x_doc_type
		   and adl_status			= 'A' ;

	END IF ;

	return x_award_id ;

END GET_AWARD_ID  ;


END gms_acc_gen_api;


/
