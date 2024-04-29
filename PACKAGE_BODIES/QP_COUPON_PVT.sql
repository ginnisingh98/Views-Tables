--------------------------------------------------------
--  DDL for Package Body QP_COUPON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_COUPON_PVT" AS
/* $Header: QPXVCPNB.pls 120.4.12010000.2 2009/12/24 08:20:08 dnema ship $ */

--  Global constant holding the package name

QP_COUPON_NOT_FOUND EXCEPTION;
QP_COUPON_MODIFIER_NOT_FOUND EXCEPTION;
QP_COUPON_QUALIFIER_NOT_FOUND EXCEPTION;
l_debug varchar2(3);


-----------------------------------------------------------------------
--Changes by spgopal
--Fix for bug 1755567
-----------------------------------------------------------------------

PROCEDURE Get_denormalized_qual_cols(p_list_header_id IN NUMBER,
                                        p_list_line_id IN NUMBER,
					x_active_flag OUT NOCOPY VARCHAR2,
                                        x_list_type_code OUT NOCOPY VARCHAR2,
                                        x_header_qual_exists_flag OUT NOCOPY VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2,
					x_return_text OUT NOCOPY VARCHAR2) IS

/*
INDX,QP_COUPON_PVT.Get_denormalized_qual_cols.l_qual_exists_cur,QP_QUALIFIERS_N1,LIST_HEADER_ID,1
INDX,QP_COUPON_PVT.Get_denormalized_qual_cols.l_qual_exists_cur,QP_QUALIFIERS_N1,LIST_LINE_ID,2
*/
CURSOR l_qual_exists_cur(p_header_id NUMBER) IS
           select 'X' qual_exists
           from qp_qualifiers
           where list_header_id=p_header_id
           and list_line_id= -1;

/*
INDX,QP_COUPON_PVT.Get_denormalized_qual_cols.l_list_hdr_dtls_cur,QP_LIST_HEADERS_B_PK,LIST_HEADER_ID,1
*/
CURSOR l_list_hdr_dtls_cur(p_header_id NUMBER) IS
           select active_flag
		, list_type_code
           from qp_list_headers_b
           where list_header_id=p_header_id;



l_qual_exists VARCHAR2(1) := FND_API.G_MISS_CHAR;

BEGIN
		OPEN l_qual_exists_cur(p_list_header_id);
		FETCH l_qual_exists_cur INTO l_qual_exists;
		CLOSE l_qual_exists_cur;

		IF l_qual_exists = 'X' THEN
			x_header_qual_exists_flag := 'Y';
		ELSE
			x_header_qual_exists_flag := 'N';
		END IF;

		OPEN l_list_hdr_dtls_cur(p_list_header_id);
		FETCH l_list_hdr_dtls_cur INTO x_active_flag, x_list_type_code;
		CLOSE l_list_hdr_dtls_cur;

x_return_status := FND_API.G_RET_STS_SUCCESS;
x_return_text := 'QP_COUPON_PVT.GET_DENORMALIZED_COLS SUCCESS';


EXCEPTION
When OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR;
x_return_text := 'QP_COUPON_PVT.GET_DENORMALIZED_COLS: '||SQLERRM;


END Get_denormalized_qual_cols;


PROCEDURE update_qual_ind(p_list_header_id IN NUMBER,
                        p_list_line_id IN NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
			x_return_text OUT NOCOPY VARCHAR2) IS

/*
INDX,QP_COUPON_PVT.update_qual_ind.l_line_qual_exists_cur,QP_QUALIFIERS_N1,LIST_HEADER_ID,1
INDX,QP_COUPON_PVT.update_qual_ind.l_line_qual_exists_cur,QP_QUALIFIERS_N1,LIST_LINE_ID,2
*/
CURSOR l_line_qual_exists_cur(p_line_id NUMBER
			     ,p_header_id NUMBER) IS
           select 'Y'
           from qp_qualifiers q
           where q.list_header_id=p_header_id
           and q.list_line_id=p_line_id;


l_qual_ind NUMBER := FND_API.G_MISS_NUM;
l_line_qual_exists VARCHAR2(1) := QP_PREQ_GRP.G_NO;
BEGIN


		OPEN l_line_qual_exists_cur(p_list_line_id, p_list_header_id);
		FETCH l_line_qual_exists_cur INTO l_line_qual_exists;
		CLOSE l_line_qual_exists_cur;

	IF l_line_qual_exists <> 'Y' THEN

/*
INDX,QP_COUPON_PVT.update_qual_ind.update_qual_ind_upd1,QP_LIST_LINES_PK,LIST_LINE_ID,1
*/
		update qp_list_lines qpl set
		qpl.qualification_ind =
		nvl(qpl.qualification_ind,0)+8
		where qpl.list_line_id=p_list_line_id
		returning qpl.qualification_ind into l_qual_ind;

/*
INDX,QP_COUPON_PVT.update_qual_ind.update_qual_ind_upd2,QP_PRICING_ATTRIBUTES_N2,LIST_LINE_ID,1
*/
		update qp_pricing_attributes pra
	        set    pra.qualification_ind = l_qual_ind
       		where  pra.list_line_id = p_list_line_id;
	END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR;
x_return_text := 'QP_COUPON_PVT.update_qual_ind : '||SQLERRM;

END update_qual_ind;

-----------------------------------------------------------------------




-- Procedure Insert_Coupon creates a record in QP_COUPONS table
PROCEDURE Insert_Coupon(
   p_issued_by_modifier_id      IN NUMBER
,  p_expiration_period_start_date                 IN DATE    := NULL
,  p_expiration_date            IN DATE    := NULL
,  p_number_expiration_periods  IN NUMBER  := NULL
,  p_expiration_period_uom_code IN VARCHAR2
,  p_user_def_coupon_number     IN VARCHAR2
,  p_pricing_effective_date   IN DATE
,  x_coupon_id                  OUT NOCOPY NUMBER
,  x_coupon_number              OUT NOCOPY VARCHAR2
,  x_return_status         OUT NOCOPY VARCHAR2
,  x_return_status_txt          OUT NOCOPY VARCHAR2
) IS
l_generated_coupon_number NUMBER;
l_expiration_period_start_date  DATE := p_expiration_period_start_date;
l_expiration_period_end_date  DATE := p_expiration_date;
l_return_status VARCHAR2(1);

BEGIN

  l_debug :=QP_PREQ_GRP.G_DEBUG_ENGINE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug ('Entering QP_COUPON_PVT.Insertr_Coupon ...');
    QP_PREQ_GRP.engine_debug ('p_issued_by_modifier_id: '||p_issued_by_modifier_id);
  END IF; -- END IF l_debug

  --DBMS_OUTPUT.PUT_LINE('Inside insert_coupon');
  /* Coupon's effective dates:
   * IF p_expiration_period_start_date is NULL, start date don't show on the coupon
   * Expiration date must be speicified or calculated
   * Per bug 1263673, We change the behavior to allow null expiration date
   * so that user has more control
  IF (p_expiration_date IS NULL AND
      (p_number_expiration_periods IS NULL OR
       p_expiration_period_uom_code IS NULL)) THEN

     FND_MESSAGE.SET_NAME('QP', 'QP_EXPIRATION_DATE_NOT_SET');

     x_return_status_txt := FND_MESSAGE.GET;

     RAISE FND_API.G_EXC_ERROR;

  END IF;
  */

  --DBMS_OUTPUT.PUT_LINE('before set expiration dates');
  QP_COUPON_PVT.Set_Expiration_Dates(
     l_expiration_period_start_date
  ,  l_expiration_period_end_date
  ,  p_number_expiration_periods
  ,  p_expiration_period_uom_code
  ,  p_pricing_effective_date
  ,  l_return_status
  ,  x_return_status_txt
  );

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SELECT QP_GENERATED_COUPON_NO_S.nextval,
  QP_COUPONS_S.nextval
  INTO l_generated_coupon_number,
  x_coupon_id
  FROM dual;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug ('coupon_id going to QP_COUPONS table (QP_COUPONS_S.nextval): '||x_coupon_id);
    QP_PREQ_GRP.engine_debug ('l_generated_coupon_number(QP_GENERATED_COUPON_NO_S.nextval): '||l_generated_coupon_number);
    QP_PREQ_GRP.engine_debug ('p_user_def_coupon_number: '||p_user_def_coupon_number);
  END IF; -- END IF l_debug

  x_coupon_number := p_user_def_coupon_number||l_generated_coupon_number;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug ('coupon_number going to QP_COUPONS table: '||x_coupon_number);
  END IF; -- END IF l_debug

  INSERT INTO QP_COUPONS(
   COUPON_ID,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   COUPON_NUMBER,
   USER_DEF_COUPON_NUMBER,
   GENERATED_COUPON_NUMBER,
   ISSUED_BY_MODIFIER_ID,
   EXPIRATION_DATE,
   START_DATE,
   REDEEMED_FLAG,
   ISSUED_DATE
   )
VALUES   (x_coupon_id,
   sysdate,
   fnd_global.user_id,
   sysdate,
   fnd_global.user_id,
   fnd_global.login_id,
   x_coupon_number,
   p_user_def_coupon_number,
   l_generated_coupon_number,
   p_issued_by_modifier_id,
   l_expiration_period_end_date,
   l_expiration_period_start_date,
   'N',
   nvl(p_pricing_effective_date,sysdate)
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

     x_return_status_txt := 'QP_COUPON_PVT.Insert_Coupon: '||SQLERRM;

     x_return_status := FND_API.G_RET_STS_ERROR;

END Insert_Coupon;

-- Procedure Create_Coupon_Qualifier creates a record in QP_QUALIFIERS table to say that
-- if your order quotes this coupon number, you can use the benefits in the coupon
PROCEDURE Create_Coupon_Qualifier(
   p_list_line_id               IN NUMBER
,  p_coupon_id                  IN NUMBER
,  x_return_status         OUT NOCOPY VARCHAR2
,  x_return_status_txt          OUT NOCOPY VARCHAR2
) IS
l_list_header_id NUMBER;
l_list_line_id NUMBER;
l_qualification_ind NUMBER;
l_qual_attr_value_from_number NUMBER := FND_API.G_MISS_NUM;
l_qual_attr_value_to_number NUMBER := FND_API.G_MISS_NUM;
l_list_type_code QP_LIST_HEADERS_B.LIST_TYPE_CODE%TYPE;
l_active_flag VARCHAR2(1);
l_header_qual_exists_flag VARCHAR2(1);
l_return_status VARCHAR2(1);
l_return_text VARCHAR2(100);

COUP_DENORMALIZED_COL_EXP EXCEPTION;
BEGIN

  l_debug :=QP_PREQ_GRP.G_DEBUG_ENGINE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug ('Entering QP_COUPON_PVT.Create_Coupon_Qualifier ...');
    QP_PREQ_GRP.engine_debug ('p_list_line_id: '||p_list_line_id);
    QP_PREQ_GRP.engine_debug ('p_coupon_id: '||p_coupon_id);
  END IF; -- END IF l_debug


  BEGIN
/*
INDX,QP_COUPON_PVT.Create_Coupon_Qualifier.Create_Coupon_Qualifier_sel1,QP_RLTD_MODIFIERS_N1,FROM_RLTD_MODIFIER_ID,1
INDX,QP_COUPON_PVT.Create_Coupon_Qualifier.Create_Coupon_Qualifier_sel1,QP_RLTD_MODIFIERS_N1,RLTD_MODIFIER_GRP_TYPE,2

INDX,QP_COUPON_PVT.Create_Coupon_Qualifier.Create_Coupon_Qualifier_sel1,QP_LIST_LINES_PK,LIST_LINE_ID,1
*/
   SELECT m.to_rltd_modifier_id list_line_id,
          l.list_header_id,
          l.qualification_ind
   INTO l_list_line_id, l_list_header_id,l_qualification_ind
   FROM qp_rltd_modifiers m, qp_list_lines l
   WHERE from_rltd_modifier_id = p_list_line_id
   AND m.to_rltd_modifier_id = l.list_line_id
   AND m.rltd_modifier_grp_type = QP_COUPON_PVT.G_COUPON_GRP_TYPE;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RAISE QP_COUPON_MODIFIER_NOT_FOUND;
  END;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug ('before calling Get_denormalized_qual_cols ...');
  END IF; -- END IF l_debug

	Get_denormalized_qual_cols(l_list_header_id,
					l_list_line_id,
					l_active_flag,
					l_list_type_code,
					l_header_qual_exists_flag,
					l_return_status,
					l_return_text);

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE COUP_DENORMALIZED_COL_EXP;
		END IF;

            l_qual_attr_value_from_number :=
            qp_number.canonical_to_number(p_coupon_id);

            l_qual_attr_value_to_number :=
            qp_number.canonical_to_number(NULL);


    /* Create a qualifier: "Coupon" = Coupon Number,context = 'Order'? */
      INSERT INTO QP_QUALIFIERS (
		QUALIFIER_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
                LIST_HEADER_ID,
                LIST_LINE_ID,
                COMPARISON_OPERATOR_CODE,
                QUALIFIER_CONTEXT,
		QUALIFIER_ATTRIBUTE,
                QUALIFIER_ATTR_VALUE,
                QUALIFIER_ATTR_VALUE_TO,
                QUALIFIER_GROUPING_NO,
                EXCLUDER_FLAG,
--changes made for bug 1755567
--included denormalised columns
		DISTINCT_ROW_COUNT,
		SEARCH_IND,
		HEADER_QUALS_EXIST_FLAG,
		QUALIFIER_GROUP_CNT,
		ACTIVE_FLAG,
		LIST_TYPE_CODE,
		QUAL_ATTR_VALUE_FROM_NUMBER,
		QUAL_ATTR_VALUE_TO_NUMBER,
                OTHERS_GROUP_CNT
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
     )
                VALUES (
		QP_QUALIFIERS_S.nextval,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
		fnd_global.login_id,
                l_list_header_id,
                l_list_line_id,
                '=',
                QP_PREQ_GRP.G_LIST_HEADER_CONTEXT,
                QP_COUPON_PVT.G_COUPON_QUALIFIER,
                to_char(p_coupon_id),
                NULL,
                qp_qualifier_group_no_s.nextval,
		'N',
		1,
		1,
		l_header_qual_exists_flag,
		(select count(*) from qp_qualifiers where list_line_id = l_list_line_id and qualifier_grouping_no = -1)+1, --[julin/5416713] accounting for -1 qualifiers
		l_active_flag,
		l_list_type_code,
		l_qual_attr_value_from_number,
		l_qual_attr_value_to_number,
                1
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(QP_QUALIFIERS_S.currval)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=l_list_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_list_header_id)
     );

	update_qual_ind(l_list_header_id,
			l_list_line_id,
			l_return_status,
			l_return_text);

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE COUP_DENORMALIZED_COL_EXP;
		END IF;

     /* In the rare case that there was no qualifier for the coupon benefit line,
        update qualification_ind because no there is a qualifier
        If set up form correctly creates dummy qualifier, this should never happen */
	   -- Not needed ... Also the old qualification indicators are no more applicable #1545351
     /* IF (l_qualification_ind = QP_PREQ_GRP.G_NO_QUAL_IND
        OR l_qualification_ind = QP_PREQ_GRP.G_NO_RLTD_QUAL_IND
        OR l_qualification_ind = QP_PREQ_GRP.G_NO_QUAL_PRIC_IND
        OR l_qualification_ind = QP_PREQ_GRP.G_BLIND_DISCOUNT_IND) THEN

        l_qualification_ind := l_qualification_ind-QP_PREQ_GRP.G_NO_QUAL_IND;

        update qp_list_lines set qualification_ind
            =decode(l_qualification_ind, 0, NULL, l_qualification_ind)
        where list_line_id = l_list_line_id;

     END IF;*/

EXCEPTION

   WHEN COUP_DENORMALIZED_COL_EXP THEN
     x_return_status_txt := 'QP_COUPON_PVT.Create_Coupon_Qualifier: '||l_return_text;

     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN QP_COUPON_MODIFIER_NOT_FOUND THEN

     fnd_message.set_name('QP', 'QP_COUPON_MODIFIER_NOT_FOUND');
     fnd_message.set_token('ID_COLUMN', 'LIST_LINE_ID');
     fnd_message.set_token('LIST_LINE_ID', p_list_line_id);
     x_return_status_txt  := fnd_message.get;

     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

     x_return_status_txt := 'QP_COUPON_PVT.Create_Coupon_Qualifier: '||SQLERRM;

     x_return_status := FND_API.G_RET_STS_ERROR;

END Create_Coupon_Qualifier;

PROCEDURE Mark_Coupon_Redeemed(
  p_coupon_number                  IN VARCHAR2
, p_pricing_effective_date        IN DATE
,  x_return_status         OUT NOCOPY VARCHAR2
,  x_return_status_txt          OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --dbms_output.put_line('passed in coupon number '||p_coupon_number);

/*
INDX,QP_COUPON_PVT.Mark_Coupon_Redeemed.Mark_Coupon_Redeemed_upd1,-No Index Used-,NA,NA
*/
    UPDATE QP_COUPONS
    SET redeemed_flag='Y'
    WHERE coupon_number = p_coupon_number;

    IF SQL%NOTFOUND THEN
      RAISE QP_COUPON_NOT_FOUND;
    END IF;

    -- Make Qualifier for the coupon Inactive
/*
INDX,QP_COUPON_PVT.Mark_Coupon_Redeemed.Mark_Coupon_Redeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_CONTEXT,1
INDX,QP_COUPON_PVT.Mark_Coupon_Redeemed.Mark_Coupon_Redeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_ATTRIBUTE,2
INDX,QP_COUPON_PVT.Mark_Coupon_Redeemed.Mark_Coupon_Redeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_ATTR_VALUE,3
INDX,QP_COUPON_PVT.Mark_Coupon_Redeemed.Mark_Coupon_Redeemed_upd2,QP_QUALIFIERS_N4,COMPARISON_OPERATOR_CODE,4
*/

/*
INDX,QP_COUPON_PVT.Mark_Coupon_Redeemed.Mark_Coupon_Redeemed_sel1,QP_COUPONS_PK,COUPON_ID,1
*/

-- Bug 9210291 - Replacing query to improve performance
   /* UPDATE qp_qualifiers
      SET end_date_active = p_pricing_effective_date
      WHERE qualifier_context= QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
      AND qualifier_attribute=QP_COUPON_PVT.G_COUPON_QUALIFIER
      AND nvl(comparison_operator_code,'=') = '='
      AND qualifier_attr_Value in
      (select coupon_id from qp_coupons where coupon_number=p_Coupon_number);*/

      UPDATE /*+ INDEX(qpq QP_QUALIFIERS_N4) */ qp_qualifiers qpq
      SET qpq.end_date_active = p_pricing_effective_date
      WHERE qpq.qualifier_context= QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
      AND qpq.qualifier_attribute=QP_COUPON_PVT.G_COUPON_QUALIFIER
      AND nvl(qpq.comparison_operator_code,'=') = '='
      AND qpq.qualifier_attr_Value in
      (select TO_CHAR(coupon_id) from qp_coupons where coupon_number=p_Coupon_number);

    IF SQL%NOTFOUND THEN
       RAISE QP_COUPON_QUALIFIER_NOT_FOUND;
    END IF;

EXCEPTION

   WHEN QP_COUPON_NOT_FOUND THEN

    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_COUPON_NUMBER');
    FND_MESSAGE.SET_TOKEN('COUPON_NUMBER', p_coupon_number);
    x_return_status_txt := FND_MESSAGE.get;
    x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN QP_COUPON_QUALIFIER_NOT_FOUND THEN

    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_COUPON_QUALIFIER');
    FND_MESSAGE.SET_TOKEN('COUPON_NUMBER', p_coupon_number);
    x_return_status_txt := FND_MESSAGE.get;
    x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

    x_return_status_txt := 'QP_COUPON_PVT.Mark_Coupon_Redeemed: '||SQLERRM;

    x_return_status := FND_API.G_RET_STS_ERROR;

END Mark_Coupon_Redeemed;

-- This is going to be obsolete, should use the overloaded version
-- with argument p_coupon_number
PROCEDURE Mark_Coupon_Unredeemed(
   p_coupon_id       IN NUMBER
,  x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
) IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

    --dbms_output.put_line('unredeem coupon id: '||p_coupon_ID);

/*
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd1,QP_COUPONS_PK,COUPON_ID,1
*/
    UPDATE QP_COUPONS
    SET redeemed_flag='N'
    WHERE coupon_id = p_coupon_id;

    -- Make Qualifier for the coupon Inactive
/*
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_CONTEXT,1
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_ATTRIBUTE,2
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_ATTR_VALUE,3
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd2,QP_QUALIFIERS_N4,COMPARISON_OPERATOR_CODE,4
*/

-- Bug 9210291 - Replacing query to improve performance.
  /*
    UPDATE qp_qualifiers
      SET end_date_active = NULL
      WHERE qualifier_context= QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
      AND qualifier_attribute=QP_COUPON_PVT.G_COUPON_QUALIFIER
      AND nvl(comparison_operator_code,'=') = '='
      AND qualifier_attr_Value=p_Coupon_ID;
   */

    UPDATE /*+ INDEX(qpq QP_QUALIFIERS_N4) */ qp_qualifiers qpq
      SET qpq.end_date_active = NULL
      WHERE qpq.qualifier_context= QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
      AND qpq.qualifier_attribute=QP_COUPON_PVT.G_COUPON_QUALIFIER
      AND nvl(qpq.comparison_operator_code,'=') = '='
      AND qpq.qualifier_attr_Value=TO_CHAR(p_Coupon_ID);

EXCEPTION

  WHEN OTHERS THEN

    x_return_status_txt := 'QP_COUPON_PVT.Mark_Coupon_Unredeemed: '||SQLERRM;
    x_return_status := FND_API.G_RET_STS_ERROR;

End Mark_Coupon_Unredeemed;

PROCEDURE Mark_Coupon_Unredeemed(
  p_coupon_number                  IN VARCHAR2
,  x_return_status         OUT NOCOPY VARCHAR2
,  x_return_status_txt          OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd1,-No Index Used-,NA,NA
*/
    UPDATE QP_COUPONS
    SET redeemed_flag='N'
    WHERE coupon_number = p_coupon_number;

    IF SQL%NOTFOUND THEN
       RAISE QP_COUPON_NOT_FOUND;
    END IF;

    -- Make Qualifier for the coupon Inactive
/*
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_CONTEXT,1
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_ATTRIBUTE,2
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd2,QP_QUALIFIERS_N4,QUALIFIER_ATTR_VALUE,3
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_upd2,QP_QUALIFIERS_N4,COMPARISON_OPERATOR_CODE,4
*/

/*
INDX,QP_COUPON_PVT.Mark_Coupon_Unredeemed.Mark_Coupon_Unredeemed_sel1,QP_COUPONS_PK,COUPON_ID,1
*/

-- Bug 9210291 - Replacing query to improve performance.
  /*
    UPDATE qp_qualifiers
      SET end_date_active = NULL
      WHERE qualifier_context= QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
      AND qualifier_attribute=QP_COUPON_PVT.G_COUPON_QUALIFIER
      AND nvl(comparison_operator_code,'=') = '='
      AND qualifier_attr_Value in
  (select coupon_id from qp_coupons where coupon_number=p_Coupon_Number);
  */

   UPDATE /*+ INDEX(qpq QP_QUALIFIERS_N4) */ qp_qualifiers qpq
      SET qpq.end_date_active = NULL
      WHERE qpq.qualifier_context= QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
      AND qpq.qualifier_attribute=QP_COUPON_PVT.G_COUPON_QUALIFIER
      AND nvl(qpq.comparison_operator_code,'=') = '='
      AND qpq.qualifier_attr_Value in
        (select TO_CHAR(coupon_id) from qp_coupons where coupon_number=p_Coupon_Number);

    IF SQL%NOTFOUND THEN
       RAISE QP_COUPON_QUALIFIER_NOT_FOUND;
    END IF;

EXCEPTION

   WHEN QP_COUPON_NOT_FOUND THEN

    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_COUPON_NUMBER');
    FND_MESSAGE.SET_TOKEN('COUPON_NUMBER', p_coupon_number);
    x_return_status_txt := FND_MESSAGE.get;
    x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN QP_COUPON_QUALIFIER_NOT_FOUND THEN

    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_COUPON_QUALIFIER');
    FND_MESSAGE.SET_TOKEN('COUPON_NUMBER', p_coupon_number);
    x_return_status_txt := FND_MESSAGE.get;
    x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

     x_return_status_txt := 'QP_COUPON_PVT.Mark_Coupon_Unredeemed: '||SQLERRM;
     x_return_status := FND_API.G_RET_STS_ERROR;

END Mark_Coupon_Unredeemed;

-- Procedure Purge_Coupon purges all redeemed and expired coupons
PROCEDURE Purge_Coupon(
    x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
INDX,QP_COUPON_PVT.Purge_Coupon.Purge_Coupon_del1,-No Index Used-,NA,NA
*/
  DELETE FROM QP_COUPONS
  WHERE redeemed_flag='Y'
  OR expiration_date < sysdate;

EXCEPTION

   WHEN OTHERS THEN

     x_return_status_txt := 'QP_COUPON_PVT.Purge_Coupon: '||SQLERRM;

     x_return_status := FND_API.G_RET_STS_ERROR;

END Purge_Coupon;

-- Procedure Delete_Coupon deletes the coupon
PROCEDURE Delete_Coupon(
  p_coupon_number                  IN VARCHAR2
,  x_return_status         OUT NOCOPY VARCHAR2
,  x_return_status_txt          OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Delete Qualifier for the coupon
/*
INDX,QP_COUPON_PVT.Delete_Coupon.Delete_Coupon_del1,QP_QUALIFIERS_N4,QUALIFIER_CONTEXT,1
INDX,QP_COUPON_PVT.Delete_Coupon.Delete_Coupon_del1,QP_QUALIFIERS_N4,QUALIFIER_ATTRIBUTE,2
INDX,QP_COUPON_PVT.Delete_Coupon.Delete_Coupon_del1,QP_QUALIFIERS_N4,QUALIFIER_ATTR_VALUE,3
INDX,QP_COUPON_PVT.Delete_Coupon.Delete_Coupon_del1,QP_QUALIFIERS_N4,COMPARISON_OPERATOR_CODE,4
*/

/*
INDX,QP_COUPON_PVT.Delete_Coupon.Delete_Coupon_sel1,QP_COUPONS_PK,COUPON_ID,1
*/
  DELETE FROM qp_qualifiers
  WHERE qualifier_context= QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
  AND qualifier_attribute=QP_COUPON_PVT.G_COUPON_QUALIFIER
  AND nvl(comparison_operator_code,'=') = '='
  AND qualifier_attr_Value in
      (select coupon_id from qp_coupons where coupon_number=p_coupon_number);

    IF SQL%NOTFOUND THEN
       RAISE QP_COUPON_QUALIFIER_NOT_FOUND;
    END IF;

/*
INDX,QP_COUPON_PVT.Delete_Coupon.Delete_Coupon_del2,-No Index Used-,NA,NA
*/
  DELETE FROM QP_COUPONS
  WHERE Coupon_number = p_Coupon_number;

    IF SQL%NOTFOUND THEN
       RAISE QP_COUPON_NOT_FOUND;
    END IF;

EXCEPTION

   WHEN QP_COUPON_NOT_FOUND THEN

    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_COUPON_NUMBER');
    FND_MESSAGE.SET_TOKEN('COUPON_NUMBER', p_coupon_number);
    x_return_status_txt := FND_MESSAGE.get;
    x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN QP_COUPON_QUALIFIER_NOT_FOUND THEN

    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_COUPON_QUALIFIER');
    FND_MESSAGE.SET_TOKEN('COUPON_NUMBER', p_coupon_number);
    x_return_status_txt := FND_MESSAGE.get;
    x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

     x_return_status_txt := 'QP_COUPON_PVT.Delete_Coupon '||SQLERRM;

     x_return_status := FND_API.G_RET_STS_ERROR;

END Delete_Coupon;

PROCEDURE Process_Coupon_Issue(
   p_line_detail_index            IN NUMBER
,  p_pricing_phase_id      IN NUMBER
,  p_line_quantity         IN NUMBER
,  p_simulation_flag       IN VARCHAR2
,  x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
) IS

  -- Get coupon issue line
/*
INDX,QP_COUPON_PVT.Process_Coupon_Issue.get_coupon_issue_lines,qp_npreq_ldets_tmp_U1,LINE_DETAIL_INDEX,1

INDX,QP_COUPON_PVT.Process_Coupon_Issue.get_coupon_issue_lines,QP_LIST_LINES_PK,LIST_LINE_ID,1
*/
  CURSOR get_coupon_issue_lines IS
       SELECT  /*+ ORDERED USE_NL(b c) */
               a.line_index,
               b.line_detail_index,
               c.price_break_type_code,
               c.Expiration_Date,
               c.expiration_period_start_date,
               c.number_expiration_periods,
               c.expiration_period_uom expiration_period_uom_code,
               c.list_header_id,
               c.list_line_id,
               c.base_qty,
               c.base_uom_code,
               c.pricing_group_sequence,
               c.list_line_no,
               c.automatic_flag,
               c.print_on_invoice_flag,
               c.override_flag,
               c.pricing_phase_id,
               c.primary_uom_flag,
               c.product_precedence,
               b.created_from_list_type_code,
               a.pricing_effective_date,
			b.line_detail_type_code,
               b.incompatability_grp_code,
               b.process_code,
               b.applied_flag,
               b.modifier_level_code
	FROM	qp_npreq_lines_tmp a ,
                qp_npreq_ldets_tmp b ,
                QP_LIST_LINES c
	WHERE   a.LINE_INDEX = b.LINE_INDEX
	AND	b.LINE_DETAIL_INDEX = p_line_detail_index
	AND	b.CREATED_FROM_LIST_LINE_ID = c.LIST_LINE_ID
        AND     b.CREATED_FROM_LIST_LINE_TYPE
          = QP_COUPON_PVT.G_COUPON_ISSUE_LINE_TYPE
        AND     b.PRICING_PHASE_ID = p_pricing_phase_id
        AND     b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;

l_number_of_coupons NUMBER := 1;
l_coupon_number  VARCHAR2(240);
l_coupon_id     NUMBER;
l_line_detail_index PLS_INTEGER;
l_return_status VARCHAR2(1);
BEGIN
    l_debug :=QP_PREQ_GRP.G_DEBUG_ENGINE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug ('Entering QP_COUPON_PVT.Process_Coupon_Issue...');
      QP_PREQ_GRP.engine_debug ('p_line_quantity: '||p_line_quantity);
    END IF; -- END IF l_debug

    FOR i IN get_coupon_issue_lines
    LOOP

        IF (i.price_break_type_code = QP_PREQ_GRP.G_RECURRING_BREAK) THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug ('RECURRING BREAK ...');
            QP_PREQ_GRP.engine_debug ('i.list_line_id: '||i.list_line_id);
          END IF; -- END IF l_debug

          qp_process_other_benefits_pvt.calculate_recurring_quantity(
           i.list_line_id,
           i.list_header_id,
           i.line_index,
            NULL,
            l_number_of_coupons,
            l_return_status,
            x_return_status_txt
           );

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug ('l_number_of_coupons: '||l_number_of_coupons);
          END IF; -- END IF l_debug

           IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

        END IF;

        IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug ('p_simulation_flag: '||p_simulation_flag);
            END IF; -- END IF l_debug

        FOR j IN 1..l_number_of_coupons
        LOOP
          -- 1. create a coupon if not a simulation
          IF (p_simulation_flag = 'N') THEN

            Insert_Coupon(i.list_line_id,
                  i.expiration_period_start_date,
                  i.expiration_date,
                  i.number_expiration_periods,
                  i.expiration_period_uom_code,
                  i.list_line_no,
                  i.pricing_effective_date,
                  l_coupon_id,
                  l_coupon_number,
                  l_return_status,
                  x_return_status_txt
                 );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            --DBMS_OUTPUT.PUT_LINE('Inserted Coupon ID: '||l_coupon_id);

            -- 2. create a qualifier: how to qualify the coupon benefits
            Create_Coupon_Qualifier(i.list_line_id,
                                   l_coupon_id,
                                   l_return_status,
                                   x_return_status_txt
                                   );

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

            --DBMS_OUTPUT.PUT_LINE('Created Qualifier');
       ELSE
            l_coupon_number := NULL;

       END IF; /* not simulation */

       IF (J = 1) THEN

         --DBMS_OUTPUT.PUT_LINE('Update Coupon No'||l_coupon_number);
/*
INDX,QP_COUPON_PVT.Process_Coupon_Issue.Process_Coupon_Issue_upd1,qp_npreq_ldets_tmp_U1,LINE_DETAIL_INDEX,1
*/
         UPDATE qp_npreq_ldets_tmp
         SET PROCESSED_FLAG = 'Y',
             LIST_LINE_NO = l_coupon_number,
             PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW,
             PRICING_STATUS_TEXT = 'Coupon_Issue'
         WHERE LINE_INDEX = i.LINE_INDEX
         AND LINE_DETAIL_INDEX = i.LINE_DETAIL_INDEX;

       ELSE

         --SELECT max(line_detail_index)
             --INTO l_line_detail_index
             --FROM qp_npreq_ldets_tmp;

	   l_line_detail_index := QP_PREQ_GRP.GET_LINE_DETAIL_INDEX;

             --DBMS_OUTPUT.PUT_LINE('max line detail'||l_line_detail_index);
             -- 3. create adjustment line

        INSERT INTO qp_npreq_ldets_tmp(
              LINE_DETAIL_INDEX,
              LINE_DETAIL_TYPE_CODE,
              LINE_INDEX,
              CREATED_FROM_LIST_HEADER_ID,
	      CREATED_FROM_LIST_LINE_ID,
              CREATED_FROM_LIST_LINE_TYPE,
              CREATED_FROM_LIST_TYPE_CODE,
              PRICING_GROUP_SEQUENCE,
              PROCESSED_FLAG,
              AUTOMATIC_FLAG,
              PRINT_ON_INVOICE_FLAG,
              OVERRIDE_FLAG,
              PRICING_PHASE_ID,
              PRIMARY_UOM_FLAG,
              PRODUCT_PRECEDENCE,
              LIST_LINE_NO,
              INCOMPATABILITY_GRP_CODE,
              PROCESS_CODE,
              APPLIED_FLAG,
              MODIFIER_LEVEL_CODE,
              PRICING_STATUS_CODE,
              PRICING_STATUS_TEXT)
	      VALUES (l_line_detail_index,
               i.line_detail_type_code,
               i.line_index,
               i.LIST_HEADER_ID,
               i.LIST_LINE_ID,
	       G_COUPON_ISSUE_LINE_TYPE,
               i.CREATED_FROM_LIST_TYPE_CODE,
               i.PRICING_GROUP_SEQUENCE,
               'Y',
               i.AUTOMATIC_FLAG,
               i.PRINT_ON_INVOICE_FLAG,
               i.OVERRIDE_FLAG,
               i.PRICING_PHASE_ID,
               i.PRIMARY_UOM_FLAG,
               i.PRODUCT_PRECEDENCE,
               l_coupon_number,
               i.incompatability_grp_code,
               i.process_code,
               i.applied_flag,
               i.modifier_level_code,
               QP_PREQ_GRP.G_STATUS_NEW,
               'Coupon Issue');

             --DBMS_OUTPUT.PUT_LINE('Inserted adjustment line');

          END IF; /* J=1, first coupon */

        END LOOP; /* number of coupons */

   END LOOP; /* coupon issue lines */

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

     x_return_status_txt := 'QP_COUPON_PVT.Process_Coupon_Issue: '||SQLERRM;

     x_return_status := FND_API.G_RET_STS_ERROR;

END Process_Coupon_Issue;

PROCEDURE Redeem_Coupons(
   p_simulation_flag    IN VARCHAR2
,  x_return_status         OUT NOCOPY VARCHAR2
,  x_return_status_txt          OUT NOCOPY VARCHAR2
)
IS

/*
INDX,QP_COUPON_PVT.Redeem_Coupons.get_coupons,qp_npreq_ldets_tmp_N7,PRICING_STATUS_CODE,1

INDX,QP_COUPON_PVT.Redeem_Coupons.get_coupons,qp_npreq_line_attrs_tmp_N7,LINE_INDEX,1
INDX,QP_COUPON_PVT.Redeem_Coupons.get_coupons,qp_npreq_line_attrs_tmp_N7,ATTRIBUTE_TYPE,2
INDX,QP_COUPON_PVT.Redeem_Coupons.get_coupons,qp_npreq_line_attrs_tmp_N7,CONTEXT,3

INDX,QP_COUPON_PVT.Redeem_Coupons.get_coupons,QP_COUPONS_PK,COUPON_ID,1

INDX,QP_COUPON_PVT.Redeem_Coupons.get_coupons,qp_npreq_lines_tmp_U1,LINE_INDEX,1
*/
 CURSOR get_coupons_ldet IS
SELECT /*+ ordered index(qplat) index( qpl)  index( qpd)*/ DISTINCT qpc.coupon_number,  --5658579
  qpl.pricing_effective_date
  FROM qp_npreq_line_attrs_tmp qplat,
       qp_npreq_ldets_tmp qpd,
       qp_npreq_lines_tmp qpl,
       qp_coupons qpc
  WHERE qplat.line_index = qpd.line_index
  and qpl.line_index = qpd.line_index
  and qplat.line_detail_index = qpd.line_detail_index
  and qplat.attribute_type= QP_PREQ_GRP.G_QUALIFIER_TYPE
  and qplat.context= QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
  and qplat.attribute=QP_COUPON_PVT.G_COUPON_QUALIFIER
  and nvl(qplat.comparison_operator_type_code,'=') = '='
  and qplat.attribute_level = QP_PREQ_GRP.G_LINE_LEVEL
  and qpd.created_from_list_line_type <> QP_COUPON_PVT.G_COUPON_ISSUE_LINE_TYPE
  and qpd.APPLIED_FLAG = QP_PREQ_GRP.G_YES
  and qpd.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
  and qpc.coupon_id = to_number(qplat.value_from);

  CURSOR get_coupons_line IS
  SELECT DISTINCT coupon_number,
  qpl.pricing_effective_date
  FROM qp_npreq_line_attrs_tmp qplat,
       qp_npreq_ldets_tmp qpd,
       qp_npreq_lines_tmp qpl,
       qp_qualifiers qpq,
       qp_coupons qpc
  WHERE qplat.line_index = qpl.line_index
  and qplat.line_detail_index is null
  and qplat.attribute_type = QP_PREQ_GRP.G_QUALIFIER_TYPE
  and qplat.context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
  and qplat.attribute = QP_COUPON_PVT.G_COUPON_QUALIFIER
  and nvl(qplat.comparison_operator_type_code,'=') = '='
  and qpq.qualifier_context = qplat.context
  and qpq.qualifier_attribute = qplat.attribute
  and qpq.QUALIFIER_ATTR_VALUE = qplat.value_from
  and qpc.coupon_id = to_number(qplat.value_from)
  and qpq.list_line_id = qpd.CREATED_FROM_LIST_LINE_ID
  and qpd.APPLIED_FLAG = QP_PREQ_PUB.G_YES
  and qpd.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW;

l_return_status VARCHAR2(1);
l_satis_quals_opt VARCHAR2(1);

BEGIN

  l_debug :=QP_PREQ_GRP.G_DEBUG_ENGINE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug ('Entering QP_COUPON_PVT.Redeem_Coupons');
  END IF;

  --dbms_output.put_line('inside redeem coupon');
  IF (p_simulation_flag = 'N') THEN

 l_satis_quals_opt := nvl(fnd_profile.VALUE('QP_SATIS_QUALS_OPT'), 'Y');
   IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('QP_SATIS_QUALS_OPT: ' || l_satis_quals_opt);
   END IF;

   -- [julin/4136528] drive off ldet attr if available (more performant),
   -- otherwise, use line attr and verify that coupon benefit (ldet) is applied.
   IF l_satis_quals_opt <> 'N' THEN
    FOR i IN get_coupons_ldet
    LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug ('found coupon'||i.coupon_number);
      END IF;

      Mark_Coupon_Redeemed(i.Coupon_Number
                        , i.pricing_effective_date
                        , l_return_status
                        , x_return_status_txt);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP;
   ELSE
    FOR i IN get_coupons_line
    LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug ('found coupon'||i.coupon_number);
      END IF;

      Mark_Coupon_Redeemed(i.Coupon_Number
                        , i.pricing_effective_date
                        , l_return_status
                        , x_return_status_txt);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP;
   END IF; -- l_satis_quals_opt

  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

     x_return_status_txt := 'QP_COUPON_PVT.Redeem_Coupons: '||SQLERRM;

     x_return_status := FND_API.G_RET_STS_ERROR;

END Redeem_Coupons;

PROCEDURE Set_Expiration_Dates(
   p_expiration_period_start_date   IN OUT NOCOPY DATE
,  p_expiration_period_end_date     IN OUT NOCOPY DATE
,  p_number_expiration_periods      IN NUMBER
,  p_expiration_period_uom_code     IN Varchar2
,  p_pricing_effective_date         IN DATE
,  x_return_status         OUT NOCOPY VARCHAR2
,  x_return_status_txt          OUT NOCOPY VARCHAR2
) IS
l_pricing_effective_date DATE := p_pricing_effective_date;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_expiration_period_end_date IS NULL) THEN

    IF (l_pricing_effective_date IS NULL) THEN
       SELECT sysdate
       INTO l_pricing_effective_date
       FROM DUAL;
    END IF;

    SELECT
      decode(p_expiration_period_uom_code,
       'YR',  add_months(nvl(p_expiration_period_start_date,l_pricing_effective_date),
                     12*p_number_expiration_periods),
       'MTH', add_months(nvl(p_expiration_period_start_date,l_pricing_effective_date),
                     p_number_expiration_periods),
       'WK', nvl(p_expiration_period_start_date,l_pricing_effective_date)
                     + 7 * p_number_expiration_periods,
       'HR', nvl(p_expiration_period_start_date,l_pricing_effective_date)
                     + p_number_expiration_periods/24,
       'MIN', nvl(p_expiration_period_start_date,l_pricing_effective_date)
                     + p_number_expiration_periods/1440,
        nvl(p_expiration_period_start_date,l_pricing_effective_date)
                     + p_number_expiration_periods)
       INTO p_expiration_period_end_date
       FROM dual;

  END IF;

EXCEPTION

   WHEN OTHERS THEN

     x_return_status_txt := 'QP_COUPON_PVT.Set_Expiration_Dates: '||SQLERRM;

     x_return_status := FND_API.G_RET_STS_ERROR;

END Set_Expiration_Dates;

END QP_COUPON_PVT;

/
