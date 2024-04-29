--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_PAY_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_PAY_ELEMENTS_PVT" AS
/* $Header: cnvqpeb.pls 115.16.115100.2 2004/05/13 00:52:57 jjhuang ship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_QUOTA_PAY_ELEMENT_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvqpeb.pls';
G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := FND_GLOBAL.USER_ID;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := FND_GLOBAL.USER_ID;
G_LAST_UPDATE_LOGIN         NUMBER  := FND_GLOBAL.LOGIN_ID;

G_PROGRAM_TYPE              VARCHAR2(30);

--+==========================================================================
--| Function : get_element_type
--| Desc :
--+==========================================================================
FUNCTION  get_element_type(p_element_type_id  NUMBER) RETURN VARCHAR2 IS

CURSOR get_element IS
 select f.element_name element_name
   from pay_element_types_f f
        ,gl_sets_of_books glsob
        ,cn_repositories cnr
 where  f.element_type_id  = p_element_type_id
   AND cnr.set_of_books_id = glsob.set_of_books_id
   AND f.input_currency_code = glsob.currency_code;

 l_name  pay_element_types_f.element_name%TYPE;

BEGIN
   open get_element;
   fetch get_element into l_name;
   close get_element;

   return l_name;
END ;
--+==========================================================================
--| Function : check_input_exists
--| Desc :
--+==========================================================================
FUNCTION  check_input_exists( p_quota_pay_element_id    NUMBER )
 RETURN NUMBER IS
  l_found  NUMBER := 0;
 BEGIN
     begin
      select 1 into l_found FROM dual
       where  not exists
        ( select 1
            from cn_pay_element_inputs
           where quota_pay_element_id = p_quota_pay_element_id);
      return 0;
     exception
      when  no_data_found THEN
       l_found := 1;
       return l_found;
     end;
END;
--+==========================================================================
--| Function : check_delete_update_Allowed
--| Desc :
--| Modified by Julia Huang for Bug 2877207.
--+==========================================================================
FUNCTION  check_delete_update_allowed( p_quota_pay_element_id    NUMBER,
				       p_start_date  DATE := NULL ,
				       p_end_date    DATE := NULL,
				       p_quota_id    NUMBER := NULL,
				       p_pay_element_type_id IN NUMBER := NULL )
 RETURN NUMBER IS

  l_found  NUMBER := 0;

 BEGIN
     IF ( p_start_date IS NOT NULL
        AND p_end_date IS NOT NULL
        AND p_quota_id IS NOT NULL
        AND p_pay_element_type_id IS NOT NULL)
    THEN
        BEGIN
            SELECT 0 INTO l_found
            FROM dual
            WHERE NOT EXISTS
            (
            SELECT 1  --if query returns row, then we can't allow update/delete.
                        --if query doesnot return anything, we can do update/delete.
            FROM
                (--Quota_id is -1000 as carry over and regular quota_id as in cn_quotas
                SELECT qpe.quota_pay_element_id,qpe.quota_id,qpe.pay_element_type_id,qpe.status,
                    MIN(ps.start_date) start_date, MAX(ps.end_date) end_date
                FROM cn_period_statuses ps,
                    cn_payment_transactions pt,
                    cn_quota_pay_elements qpe,
                    cn_salesreps cs,
                    cn_quotas cq
                WHERE pt.credited_salesrep_id = cs.salesrep_id
                AND pt.pay_period_id  = ps.period_id
                AND pt.pay_element_type_id = qpe.pay_element_type_id
                AND cq.quota_id = DECODE(pt.quota_id,-1000, cq.quota_id, pt.quota_id)
                AND pt.quota_id = qpe.quota_id
                AND nvl(cs.status, 'A') = qpe.status
                AND cq.start_date <= NVL(cs.end_date_active, cq.start_date)
                AND cs.start_date_active <= NVL( cq.end_date, cs.start_date_active)
                AND qpe.start_date <= NVL( cq.end_date, qpe.start_date)
                AND cq.start_date <= NVL( qpe.end_date, cq.start_date)
                AND qpe.start_date <= NVL( cs.end_date_active, qpe.start_date)
                AND cs.start_date_active <= NVL( qpe.end_date, cs.start_date_active)
                GROUP BY qpe.quota_pay_element_id,qpe.quota_id,qpe.pay_element_type_id,qpe.status
                UNION ALL
                --Quota_id is -1001 as 'PMTPLN_REC' type.
                SELECT qpe.quota_pay_element_id,qpe.quota_id,qpe.pay_element_type_id,qpe.status,
                    MIN(ps.start_date) start_date, MAX(ps.end_date) end_date
                FROM cn_period_statuses ps,
                    cn_payment_transactions pt,
                    cn_quota_pay_elements qpe,
                    cn_salesreps cs,
                    cn_quotas cq
                WHERE pt.credited_salesrep_id = cs.salesrep_id
                AND pt.pay_period_id  = ps.period_id
                AND pt.pay_element_type_id = qpe.pay_element_type_id
                AND cq.quota_id = DECODE(pt.quota_id,-1000, cq.quota_id, pt.quota_id)
                AND pt.quota_id = DECODE(qpe.quota_id,-1001, pt.quota_id,qpe.quota_id)
                AND qpe.quota_id = -1001
                AND pt.incentive_type_code = 'PMTPLN_REC'
                AND nvl(cs.status, 'A') = qpe.status
                AND cq.start_date <= NVL(cs.end_date_active, cq.start_date)
                AND cs.start_date_active <= NVL( cq.end_date, cs.start_date_active)
                AND qpe.start_date <= NVL( cq.end_date, qpe.start_date)
                AND cq.start_date <= NVL( qpe.end_date, cq.start_date)
                AND qpe.start_date <= NVL( cs.end_date_active, qpe.start_date)
                AND cs.start_date_active <= NVL( qpe.end_date, cs.start_date_active)
                GROUP BY qpe.quota_pay_element_id,qpe.quota_id,qpe.pay_element_type_id,qpe.status
                ) v
            WHERE v.quota_pay_element_id = p_quota_pay_element_id
            AND ( (p_end_date < v.end_date OR p_start_date > v.start_date)
                OR v.quota_id <> p_quota_id
                OR v.pay_element_type_id <> p_pay_element_type_id
                )
            );

        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_found := 1;
        END;

    ELSE
        BEGIN
            SELECT 0 INTO l_found
            FROM dual
            WHERE NOT EXISTS
            (
            SELECT 1  --if query returns row, then we can't allow update/delete.
                        --if query doesnot return anything, we can do update/delete.
            FROM
                (--Quota_id is -1000 as carry over and regular quota_id as in cn_quotas
                SELECT qpe.quota_pay_element_id,qpe.quota_id,qpe.pay_element_type_id,qpe.status,
                    MIN(ps.start_date) start_date, MAX(ps.end_date) end_date
                FROM cn_period_statuses ps,
                    cn_payment_transactions pt,
                    cn_quota_pay_elements qpe,
                    cn_salesreps cs,
                    cn_quotas cq
                WHERE pt.credited_salesrep_id = cs.salesrep_id
                AND pt.pay_period_id  = ps.period_id
                AND pt.pay_element_type_id = qpe.pay_element_type_id
                AND cq.quota_id = DECODE(pt.quota_id,-1000, cq.quota_id, pt.quota_id)
                AND pt.quota_id = qpe.quota_id
                AND nvl(cs.status, 'A') = qpe.status
                AND cq.start_date <= NVL(cs.end_date_active, cq.start_date)
                AND cs.start_date_active <= NVL( cq.end_date, cs.start_date_active)
                AND qpe.start_date <= NVL( cq.end_date, qpe.start_date)
                AND cq.start_date <= NVL( qpe.end_date, cq.start_date)
                AND qpe.start_date <= NVL( cs.end_date_active, qpe.start_date)
                AND cs.start_date_active <= NVL( qpe.end_date, cs.start_date_active)
                GROUP BY qpe.quota_pay_element_id,qpe.quota_id,qpe.pay_element_type_id,qpe.status
                UNION ALL
                --Quota_id is -1001 as 'PMTPLN_REC' type.
                SELECT qpe.quota_pay_element_id,qpe.quota_id,qpe.pay_element_type_id,qpe.status,
                    MIN(ps.start_date) start_date, MAX(ps.end_date) end_date
                FROM cn_period_statuses ps,
                    cn_payment_transactions pt,
                    cn_quota_pay_elements qpe,
                    cn_salesreps cs,
                    cn_quotas cq
                WHERE pt.credited_salesrep_id = cs.salesrep_id
                AND pt.pay_period_id  = ps.period_id
                AND pt.pay_element_type_id = qpe.pay_element_type_id
                AND cq.quota_id = DECODE(pt.quota_id,-1000, cq.quota_id, pt.quota_id)
                AND pt.quota_id = DECODE(qpe.quota_id,-1001, pt.quota_id,qpe.quota_id)
                AND qpe.quota_id = -1001
                AND pt.incentive_type_code = 'PMTPLN_REC'
                AND nvl(cs.status, 'A') = qpe.status
                AND cq.start_date <= NVL(cs.end_date_active, cq.start_date)
                AND cs.start_date_active <= NVL( cq.end_date, cs.start_date_active)
                AND qpe.start_date <= NVL( cq.end_date, qpe.start_date)
                AND cq.start_date <= NVL( qpe.end_date, cq.start_date)
                AND qpe.start_date <= NVL( cs.end_date_active, qpe.start_date)
                AND cs.start_date_active <= NVL( qpe.end_date, cs.start_date_active)
                GROUP BY qpe.quota_pay_element_id,qpe.quota_id,qpe.pay_element_type_id,qpe.status
                ) v
            WHERE  v.quota_pay_element_id = p_quota_pay_element_id
            AND (p_end_date < v.end_date OR p_start_date > v.start_date)
            );

        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_found := 1;
        END;

    END IF;

    RETURN l_found;
 END ;
--+==========================================================================
--| Function : get quota ID
--| Desc :
--| Modified by Julia Huang on 5/12/04 for bug 3626385.  Use cn_quotas and
--| cn_lookups instead of cn_quota_lookups_v.
--+==========================================================================
FUNCTION  get_Quota_id( p_quota_name    VARCHAR2)
  RETURN cn_quotas.quota_id%TYPE IS

   l_quota_id      cn_quotas.quota_id%TYPE;

    --Bug 3626385
    l_cnt NUMBER;

    CURSOR get_qid_quotas IS
        SELECT quota_id
        FROM cn_quotas
        WHERE name = p_quota_name;

    CURSOR get_qid_lkup IS
        SELECT v.quota_id
        FROM
            (SELECT TO_NUMBER(lookup_code) quota_id, meaning name
            FROM cn_lookups
            WHERE lookup_type = 'ELEMENT_TYPE'
            ) v
        WHERE v.name = p_quota_name;

BEGIN
   /* commented out by Julia Huang for bug 3626385.
   SELECT quota_id INTO l_quota_id
     FROM cn_quota_lookups_v
     WHERE name = p_quota_name;
   */

    l_cnt := 0;
    FOR i IN get_qid_quotas
    LOOP
        l_quota_id := i.quota_id;
        l_cnt := l_cnt + 1;
    END LOOP;

    IF l_cnt = 0
    THEN
        FOR i IN get_qid_lkup
        LOOP
            l_quota_id := i.quota_id;
            l_cnt := l_cnt + 1;
        END LOOP;
    END IF;

    IF l_cnt = 0
    THEN
        l_quota_id := NULL;
    END IF;

    RETURN l_quota_id;

/* commented out by Julia Huang for bug 3626385.
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
*/
END get_quota_id;
--+==========================================================================
--| Proceudre : get Pay Element type ID
--| Desc :
--+==========================================================================
PROCEDURE get_pay_element_id( p_pay_element_name    VARCHAR2,
			      p_start_date	    DATE,
			      p_end_Date	    DATE,
                              x_element_type_id     OUT NOCOPY NUMBER ) IS

  CURSOR get_functional_currency IS
      SELECT currency_code
        FROM gl_sets_of_books glsob,
        cn_repositories cnr
        WHERE cnr.set_of_books_id = glsob.set_of_books_id;

      l_functional_currency gl_sets_of_books.currency_code%TYPE;

BEGIN

   OPEN get_functional_currency;
   FETCH get_functional_currency INTO l_functional_currency;
   CLOSE get_functional_currency;

   SELECT element_type_id
     INTO x_element_type_id
     FROM pay_element_types_f
     WHERE element_name = p_pay_element_name
       AND input_currency_code = l_functional_currency
       AND p_start_date between effective_start_date and  effective_end_date
       AND effective_end_date >= nvl(p_end_date,  effective_end_date);

EXCEPTION
   WHEN no_data_found THEN
     NULL;

   WHEN too_many_rows THEN
    NULL;
END get_pay_element_id;

--+==========================================================================
--| Procedure : valid_qpe_mapping
--| Desc : Procedure to validate quota pay element mapping
--+==========================================================================
 PROCEDURE valid_qpe_mapping
  (
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER   ,
   x_msg_data               OUT NOCOPY VARCHAR2 ,
   p_quota_pay_element_rec  IN  quota_pay_element_rec_type
                            := G_MISS_QUOTA_PAY_ELEMENT_REC,
   p_action                 IN VARCHAR2,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   )
  IS
     l_api_name      CONSTANT VARCHAR2(30) := 'valid_qpe_mapping';
     l_null_date     CONSTANT DATE         := to_date('31-12-4000','DD-MM-YYYY');

     l_dummy         NUMBER;

     l_quota_id      NUMBER;

    cursor get_old( p_quota_pay_element_id NUMBER) is
     select *
       from cn_quota_pay_elements
      where quota_pay_element_id = p_quota_pay_element_id;

     l_old_rec get_old%ROWTYPE;

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;
   -- API body

  IF  p_quota_pay_element_rec.quota_name IS NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_QUOTA_NAME_NOT_NULL');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_QUOTA_NAME_NOT_NULL';
	 RAISE FND_API.G_EXC_ERROR ;
    END IF;


  IF  p_quota_pay_element_rec.pay_element_name IS NULL THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_PAY_ELEMENT_NAME_NOT_NULL');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PAY_ELEMENT_NAME_NOT_NULL';
	 RAISE FND_API.G_EXC_ERROR ;
  END IF;


   IF  p_quota_pay_element_rec.quota_name IS NOT NULL and
       p_quota_pay_element_rec.quota_id IS NULL THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_QUOTA_NOT_EXISTS');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_QUOTA_NOT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
    END IF;


   IF  p_quota_pay_element_rec.start_date IS NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_PAY_ELEMENT_SD_NOT_NULL');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PAY_ELEMENT_SD_NOT_NULL';
	 RAISE FND_API.G_EXC_ERROR ;
    END IF;

   IF  p_quota_pay_element_rec.end_date IS NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_PAY_ELEMENT_ED_NOT_NULL');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PAY_ELEMENT_ED_NOT_NULL';
	 RAISE FND_API.G_EXC_ERROR ;
    END IF;

   -- Invalid Date Range
   IF p_quota_pay_element_rec.pay_start_date IS NOT NULL AND
      p_quota_pay_element_rec.pay_end_date IS NOT NULL THEN

    IF NOT ( p_quota_pay_element_rec.start_date
          between  p_quota_pay_element_rec.pay_start_date
              and  p_quota_pay_element_rec.pay_end_date) or
                   p_quota_pay_element_rec.pay_end_date <
                   p_quota_pay_element_rec.end_date THEN

         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_PE_DATE_NOT_WITHIN_PAY_PE');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PE_DATE_NOT_WITHIN_PAY_PE';
	 RAISE FND_API.G_EXC_ERROR ;
   END IF;

  END IF;


   IF  p_quota_pay_element_rec.pay_element_name IS NOT NULL and
       p_quota_pay_element_rec.pay_element_type_id IS NULL THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_PAY_ELEMENT_NOT_EXISTS');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PAY_ELEMENT_NOT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
   END IF;



  -- Check for duplicate
  BEGIN
    SELECT 1 INTO l_dummy FROM dual
      WHERE NOT EXISTS
      ( SELECT 1
	FROM cn_quota_pay_elements
	WHERE quota_id =  p_quota_pay_element_rec.quota_id
	AND   pay_element_type_id  = p_quota_pay_element_rec.pay_element_type_id
	AND   nvl(status,'A') =  nvl(p_quota_pay_element_rec.status,'A')
	AND   start_date = p_quota_pay_element_rec.start_date
	AND   ( (end_date = p_quota_pay_element_rec.end_date) OR
		(end_date IS NULL AND p_quota_pay_element_rec.end_date IS NULL) )
	AND   ((p_quota_pay_element_rec.quota_pay_element_id IS NOT NULL AND
		quota_pay_element_id <> p_quota_pay_element_rec.quota_pay_element_id)
	       OR
	       (p_quota_pay_element_rec.quota_pay_element_id IS NULL))
       );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_QUOTA_PAY_ELEMENT_EXISTS');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_QUOTA_PAY_ELEMENT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
   END;

   -- Check if date range invalid
   -- will check : if start_date is null
   --              if start_date/end_date is missing
   --              if start_date > end_date
    IF ( (cn_api.invalid_date_range
	  (p_start_date => p_quota_pay_element_rec.start_date,
	   p_end_date => p_quota_pay_element_rec.end_date,
	   p_end_date_nullable => FND_API.G_TRUE,
	   p_loading_status => x_loading_status,
	   x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
       RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check for Overlap
   BEGIN
      SELECT 1 INTO l_dummy FROM dual
	WHERE NOT EXISTS
	( SELECT 1
	  FROM   cn_quota_pay_elements
	  WHERE (((end_date IS NULL)
		  AND (p_quota_pay_element_rec.end_date IS NULL))
		 OR
		 ((end_date IS NULL) AND
		  (p_quota_pay_element_rec.end_date IS NOT NULL) AND
		  ((p_quota_pay_element_rec.start_date >= start_date) OR
		   (start_date BETWEEN p_quota_pay_element_rec.start_date
		    AND p_quota_pay_element_rec.end_date))
		  )
		 OR
		 ((end_date IS NOT NULL) AND
		  (p_quota_pay_element_rec.end_date IS NULL) AND
		  ((p_quota_pay_element_rec.start_date <= start_date) OR
		   (p_quota_pay_element_rec.start_date BETWEEN start_date
		    AND end_date))
		  )
		 OR
		 ((end_date IS NOT NULL) AND
		  (p_quota_pay_element_rec.end_date IS NOT NULL) AND
		  ((start_date BETWEEN p_quota_pay_element_rec.start_date
		    AND p_quota_pay_element_rec.end_date) OR
		   (end_date BETWEEN p_quota_pay_element_rec.start_date
		    AND p_quota_pay_element_rec.end_date) OR
		   (p_quota_pay_element_rec.start_date BETWEEN start_date
		    AND end_date))
		  )
		 )
	  AND ((p_quota_pay_element_rec.quota_pay_element_id IS NOT NULL AND
		quota_pay_element_id <> p_quota_pay_element_rec.quota_pay_element_id)
	       OR
	       (p_quota_pay_element_rec.quota_pay_element_id IS NULL))
	   AND quota_id = p_quota_pay_element_rec.quota_id
           --AND pay_element_type_id  = p_quota_pay_element_rec.pay_element_type_id
          AND nvl(status,'A')      = nvl(p_quota_pay_element_rec.status,'A')
	);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_QUOTA_PAY_ELEMENT_OVERLAPS');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_QUOTA_PAY_ELEMENT_OVERLAPS';
	 RAISE FND_API.G_EXC_ERROR ;
   END;

   IF p_quota_pay_element_rec.quota_pay_element_id IS NOT NULL
     AND p_quota_pay_element_rec.quota_pay_element_id <> 0 THEN

     open get_old(p_quota_pay_element_rec.quota_pay_element_id);
     fetch get_old into l_old_rec;
     close get_old;
     if   trunc(p_quota_pay_element_rec.start_date)   > trunc(l_old_rec.start_date) or
          trunc(p_quota_pay_element_rec.end_date)     < trunc(l_old_rec.end_date) or
          p_quota_pay_element_rec.pay_element_type_id <> l_old_rec.pay_element_type_id or
          p_quota_pay_element_rec.quota_id <> l_old_rec.quota_id or
          p_quota_pay_element_rec.status   <> l_old_rec.status
      then
	if check_delete_update_allowed(p_quota_pay_element_rec.quota_pay_element_id,
				       p_quota_pay_element_rec.start_date,
				       p_quota_pay_element_rec.end_date,
				       p_quota_pay_element_rec.quota_id,
				       p_quota_pay_element_rec.pay_element_type_id) > 0 THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_PAY_ELEMENT_ALREADY_USED');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PAY_ELEMENT_ALREADY_USED';
	 RAISE FND_API.G_EXC_ERROR ;
     end if;

      if  p_quota_pay_element_rec.pay_element_type_id <> l_old_rec.pay_element_type_id THEN
      if check_input_exists(p_quota_pay_element_rec.quota_pay_element_id) > 0 THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_ELEMENT_INPUT_EXISTS');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_ELEMENT_INPUT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
       end if;

      end if;
    end if;

  END IF;


   -- End of API body.
   << end_valid_pp_assign >>
     NULL ;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;

END valid_qpe_mapping;
--+==========================================================================
--| Procedure : Create_quota_pay_element
--| Desc : Procedure to create a new payment plan assignment to salesrep
--+==========================================================================

PROCEDURE Create_quota_pay_element
  (
   p_api_version           IN    NUMBER,
   p_init_msg_list	   IN    VARCHAR2,
   p_commit	           IN    VARCHAR2,
   p_validation_level      IN    NUMBER,
   x_return_status	   OUT NOCOPY   VARCHAR2,
   x_msg_count	           OUT NOCOPY   NUMBER,
   x_msg_data	           OUT NOCOPY   VARCHAR2,
   p_quota_pay_element_rec IN    quota_pay_element_rec_type
                              := G_MISS_QUOTA_PAY_ELEMENT_REC,
   x_quota_pay_element_id  OUT NOCOPY   NUMBER,
   x_loading_status        OUT NOCOPY   VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Create_quota_pay_element';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_quota_pay_element_rec      quota_pay_element_rec_type := G_MISS_QUOTA_PAY_ELEMENT_REC;
      l_qpe_row      cn_quota_pay_elements%ROWTYPE ;

      l_salesrep_id  cn_srp_pmt_plans.salesrep_id%TYPE;
      l_role_id      cn_srp_pmt_plans.role_id%TYPE;
      l_start_date   cn_srp_pmt_plans.start_date%TYPE;
      l_end_date     cn_srp_pmt_plans.end_date%TYPE;
      l_action       VARCHAR2(30) := 'CREATE';

BEGIN
    -- Standard Start of API savepoint
   SAVEPOINT	Create_quota_pay_element;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- Assign the parameter to a local variable

   l_quota_pay_element_rec := p_quota_pay_element_rec;

   -- Trim spaces before/after user input string, get Value-Id para assigned
   SELECT
    Decode(p_quota_pay_element_rec.quota_pay_element_id,
	    FND_API.G_MISS_NUM, NULL ,
	    p_quota_pay_element_rec.quota_pay_element_id),
     Decode(p_quota_pay_element_rec.quota_id,
	    FND_API.G_MISS_NUM, NULL ,
	    p_quota_pay_element_rec.quota_id ),
     Decode(p_quota_pay_element_rec.pay_element_type_id,
	    FND_API.G_MISS_NUM, NULL ,
	    p_quota_pay_element_rec.pay_element_type_id),
     Decode(p_quota_pay_element_rec.status,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_quota_pay_element_rec.status),
     Decode(p_quota_pay_element_rec.start_date,
	    FND_API.G_MISS_DATE,To_date(NULL) ,
	    trunc(p_quota_pay_element_rec.start_date)),
     Decode(p_quota_pay_element_rec.end_date,
	    FND_API.G_MISS_DATE,To_date(NULL) ,
	    trunc(p_quota_pay_element_rec.end_date)),
     Decode(p_quota_pay_element_rec.quota_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_quota_pay_element_rec.quota_name),
     Decode(p_quota_pay_element_rec.pay_element_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_quota_pay_element_rec.pay_element_name),
     Decode(p_quota_pay_element_rec.pay_start_date,
	    FND_API.G_MISS_DATE, NULL ,
	    p_quota_pay_element_rec.pay_start_date),
    Decode(p_quota_pay_element_rec.pay_end_date,
	    FND_API.G_MISS_DATE, NULL ,
	    p_quota_pay_element_rec.pay_end_date)
     INTO
      l_quota_pay_element_rec.quota_pay_element_id,
      l_quota_pay_element_rec.quota_id,
      l_quota_pay_element_rec.pay_element_type_id,
      l_quota_pay_element_rec.status,
      l_quota_pay_element_rec.start_date,
      l_quota_pay_element_rec.end_date,
      l_quota_pay_element_rec.quota_name,
      l_quota_pay_element_rec.pay_element_name,
      l_quota_pay_element_rec.pay_start_date,
      l_quota_pay_element_rec.pay_end_date
     FROM dual;

     -- get the quota id

    l_quota_pay_element_rec.quota_id :=
    get_quota_id(l_quota_pay_element_rec.quota_name);

    -- get pay element name
   get_pay_element_id
   (p_pay_element_name => l_quota_pay_element_rec.pay_element_name,
    p_start_date	       => l_quota_pay_element_rec.start_date,
   p_end_Date	       => l_quota_pay_element_rec.end_date,
   x_element_type_id   => l_quota_pay_element_rec.pay_element_type_id);

   --
   -- Valid payment plan assignment
   --
    valid_qpe_mapping
     ( x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_quota_pay_element_rec => l_quota_pay_element_rec,
       p_action                => l_action,
       p_loading_status        => x_loading_status,
       x_loading_status        => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSE
    -- Create cn_quota_pay_elements
      cn_quota_pay_elements_pkg.insert_row
	(x_quota_pay_element_id  => l_quota_pay_element_rec.quota_pay_element_id
	 ,p_quota_id             => l_quota_pay_element_rec.quota_id
	 ,p_pay_element_type_id  => l_quota_pay_element_rec.pay_element_type_id
	 ,p_status               => l_quota_pay_element_rec.status
	 ,p_start_date           => l_quota_pay_element_rec.start_date
	 ,p_end_date             => l_quota_pay_element_rec.end_date
	 ,p_last_update_date     => G_LAST_UPDATE_DATE
	 ,p_last_updated_by      => G_LAST_UPDATED_BY
	 ,p_creation_date        => G_CREATION_DATE
	 ,p_created_by           => G_CREATED_BY
	 ,p_last_update_login    => G_LAST_UPDATE_LOGIN
	 );
   END IF;
   --
   -- End of API body.
   --

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_quota_pay_element;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_quota_pay_element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_quota_pay_element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

  END create_quota_pay_element;

--+==========================================================================
--| Procedure : Update_quota_pay_element
--| Desc :
--+==========================================================================

PROCEDURE Update_quota_pay_element
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list	IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status	OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   po_quota_pay_element_rec IN  quota_pay_element_rec_type
                              := G_MISS_quota_pay_element_rec,
   p_quota_pay_element_rec IN quota_pay_element_rec_type:=G_MISS_QUOTA_PAY_ELEMENT_REC,
   x_loading_status     OUT NOCOPY   VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Uupdate_Quota_Pay_Element';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_quota_pay_element_rec     quota_pay_element_rec_type := G_MISS_QUOTA_PAY_ELEMENT_REC ;
      l_action         VARCHAR2(30) := 'UPDATE';

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT	Update_quota_pay_element;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   -- Assign the parameter to a local variable
   l_quota_pay_element_rec := p_quota_pay_element_rec;

   -- Trim spaces before/after user input string (New record) if missing,
   -- assign the old value into it

   SELECT
     Decode(p_quota_pay_element_rec.quota_pay_element_id,
	    FND_API.G_MISS_NUM, null,
            p_quota_pay_element_rec.quota_pay_element_id),
     Decode(p_quota_pay_element_rec.quota_id,
	    FND_API.G_MISS_NUM, null,
	    p_quota_pay_element_rec.quota_id),
     Decode(p_quota_pay_element_rec.pay_element_type_id,
	    FND_API.G_MISS_NUM,  null,
	    p_quota_pay_element_rec.pay_element_type_id),
     Decode(p_quota_pay_element_rec.status,
	    FND_API.G_MISS_CHAR,  p_quota_pay_element_rec.status,
	    Ltrim(Rtrim(p_quota_pay_element_rec.status))),
     Decode(p_quota_pay_element_rec.start_date,
	    FND_API.G_MISS_DATE, p_quota_pay_element_rec.start_date,
	    trunc(p_quota_pay_element_rec.start_date)),
     Decode(p_quota_pay_element_rec.end_date,
	    FND_API.G_MISS_DATE, p_quota_pay_element_rec.end_date,
	    trunc(p_quota_pay_element_rec.end_date)),
     Decode(p_quota_pay_element_rec.quota_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_quota_pay_element_rec.quota_name),
     Decode(p_quota_pay_element_rec.pay_element_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_quota_pay_element_rec.pay_element_name)
     INTO
      l_quota_pay_element_rec.quota_pay_element_id,
      l_quota_pay_element_rec.quota_id,
      l_quota_pay_element_rec.pay_element_type_id,
      l_quota_pay_element_rec.status,
      l_quota_pay_element_rec.start_date,
      l_quota_pay_element_rec.end_date,
      l_quota_pay_element_rec.quota_name,
      l_quota_pay_element_rec.pay_element_name
     FROM dual;

    l_quota_pay_element_rec.quota_id :=
    get_quota_id(l_quota_pay_element_rec.quota_name);


    -- get pay element name
    get_pay_element_id
   (p_pay_element_name => l_quota_pay_element_rec.pay_element_name,
   p_start_date	       => l_quota_pay_element_rec.start_date,
   p_end_Date	       => l_quota_pay_element_rec.end_date,
   x_element_type_id   => l_quota_pay_element_rec.pay_element_type_id);


    -- Valid payment plan assignment
    valid_qpe_mapping
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_quota_pay_element_rec => l_quota_pay_element_rec,
       p_action         => l_action,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status
       );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSE
      -- Update
      cn_quota_pay_elements_pkg.update_row
	(p_quota_pay_element_id  => l_quota_pay_element_rec.quota_pay_element_id
	 ,p_quota_id             => l_quota_pay_element_rec.quota_id
	 ,p_pay_element_type_id  => l_quota_pay_element_rec.pay_element_type_id
	 ,p_status               => l_quota_pay_element_rec.status
	 ,p_start_date           => l_quota_pay_element_rec.start_date
	 ,p_end_date             => l_quota_pay_element_rec.end_date
	 ,p_last_update_date     => G_LAST_UPDATE_DATE
	 ,p_last_updated_by      => G_LAST_UPDATED_BY
	 ,p_last_update_login    => G_LAST_UPDATE_LOGIN
	 );
   END IF;
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_quota_pay_element;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_quota_pay_element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_quota_pay_element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Update_quota_pay_element;
--============================================================================
--| Procedure : Delete_quota_pay_element
--|
--============================================================================
 PROCEDURE Delete_quota_pay_element
  (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2 := CN_API.G_FALSE,
   p_commit	          IN  VARCHAR2 := CN_API.G_FALSE,
   p_validation_level     IN  NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count	          OUT NOCOPY NUMBER,
   x_msg_data	          OUT NOCOPY VARCHAR2,
   p_quota_pay_element_id IN  NUMBER,
   x_loading_status       OUT NOCOPY VARCHAR2
) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Quota_Pay_Element';
      l_api_version  CONSTANT NUMBER  := 1.0;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT	 Delete_Quota_Pay_element;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   IF p_quota_pay_element_id IS NOT NULL THEN

    if check_delete_update_allowed(p_quota_pay_element_id) > 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_PAY_ELEMENT_ALREADY_USED');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PAY_ELEMENT_ALREADY_USED';
	 RAISE FND_API.G_EXC_ERROR ;
    end if;

    if check_input_exists(p_quota_pay_element_id) > 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_ELEMENT_INPUT_EXISTS');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_ELEMENT_INPUT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
    end if;


  END IF;

   -- Delete record
   cn_quota_pay_elements_pkg.delete_row
     (p_quota_pay_element_id      =>p_quota_pay_element_id);
   --
   -- End of API body.
   --
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Quota_Pay_element;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Quota_Pay_Element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Quota_Pay_element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END Delete_Quota_Pay_Element;
--============================================================================
--| Procedure : Get_quota_pay_Element
--|
--============================================================================
   PROCEDURE  Get_quota_pay_element
   ( p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2,
     p_commit                IN   VARCHAR2,
     p_validation_level      IN   NUMBER,
     x_return_status         OUT NOCOPY  VARCHAR2,
     x_msg_count             OUT NOCOPY  NUMBER,
     x_msg_data              OUT NOCOPY  VARCHAR2,
     p_quota_name            IN   cn_quotas.name%TYPE,
     p_pay_element_name      IN   pay_element_types.element_name%TYPE,
     p_start_record          IN   NUMBER,
     p_increment_count       IN   NUMBER,
     p_order_by              IN   VARCHAR2,
     x_quota_pay_element_tbl OUT NOCOPY  quota_pay_element_out_tbl_type,
     x_total_records         OUT NOCOPY  NUMBER,
     x_status                OUT NOCOPY  VARCHAR2,
     x_loading_status        OUT NOCOPY  VARCHAR2
     ) IS

    TYPE quotacurtype IS ref CURSOR;

    quota_cur quotacurtype;


      l_api_name         CONSTANT VARCHAR2(30)  := 'Get_quota_pay_element';
      l_api_version                CONSTANT NUMBER        := 1.0;

      l_counter NUMBER;

      l_quota_pay_element_id NUMBER;
      l_quota_id             NUMBER;
      l_pay_element_type_id  NUMBER;
      l_status               cn_quota_pay_elements.status%TYPE;
      l_start_date           DATE;
      l_end_date             DATE;

      l_quota_name           cn_quotas.name%type;
      l_element_name         pay_element_types.element_name%TYPE;
      l_e_start_date         DATE;
      l_e_end_date           DATE;

   l_select varchar2(4000) := 'SELECT cqpe.quota_pay_element_id,
           cqpe.quota_id,
           cqpe.pay_element_type_id,
           cqpe.status,
           cqpe.start_date,
           cqpe.end_date,
           cq.name,
           cpet.element_name,
           cpet.effective_start_date,
           cpet.effective_end_Date
     FROM cn_quota_pay_elements cqpe,
          pay_element_types_f  cpet,
          cn_quota_lookups_v cq,
          gl_sets_of_books glsob,
          cn_repositories cnr
      where
            cnr.set_of_books_id      = glsob.set_of_books_id
       AND  cpet.input_currency_code = glsob.currency_code
       AND  cqpe.quota_id = cq.quota_id
       AND  cqpe.pay_element_type_id = cpet.element_type_id
       And  cqpe.start_date >= cpet.effective_start_date
       AND  cqpe.end_date <= cpet.effective_end_Date
       AND upper(cq.name)   like  upper(:B1)
       AND upper(cpet.element_name) like upper(:B2) ';

   l_select1 varchar2(4000) := 'SELECT cqpe.quota_pay_element_id,
           cqpe.quota_id,
           cqpe.pay_element_type_id,
           cqpe.status,
           cqpe.start_date,
           cqpe.end_date,
           cq.name,
           cpet.element_name,
           cpet.effective_start_date,
           cpet.effective_end_Date
     FROM cn_quota_pay_elements cqpe,
          pay_element_types_f  cpet,
          cn_quota_lookups_v cq,
          gl_sets_of_books glsob,
          cn_repositories cnr
      where
            cnr.set_of_books_id      = glsob.set_of_books_id
       AND  cpet.input_currency_code = glsob.currency_code
       AND  cqpe.quota_id = cq.quota_id
       AND  cqpe.pay_element_type_id = cpet.element_type_id
       And  cqpe.start_date >= cpet.effective_start_date
       AND  cqpe.end_date <= cpet.effective_end_Date  ';

  BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Get_quota_pay_element;
   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                         p_api_version ,
                         l_api_name    ,
                         G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'SELECTED';
   --
   -- API body
   --
   l_counter := 0;

   x_total_records := 0;

   if (( p_quota_name is null or p_quota_name = '%') and
        (p_pay_element_name is null or p_pay_element_name = '%')) THEN

     l_select := l_select1;

   end if;

    if (( p_quota_name is null or p_quota_name = '%') and
        (p_pay_element_name is null or p_pay_element_name = '%')) THEN

        OPEN quota_cur FOR l_select;

    else
        OPEN quota_cur  FOR l_select using p_quota_name, p_pay_element_name  ;
   end if;

   LOOP

     FETCH quota_cur INTO
      l_quota_pay_element_id
      ,l_quota_id
      ,l_pay_element_type_id
      ,l_status
      ,l_start_date
      ,l_end_date
      ,l_quota_name
      ,l_element_name
      ,l_e_start_date
      ,l_e_end_date;

     EXIT WHEN quota_cur%notfound;
     x_total_records := x_total_records + 1;

     IF (l_counter + 1 BETWEEN p_start_record
         AND (p_start_record + p_increment_count - 1))
       THEN
         x_quota_pay_element_tbl(l_counter).quota_pay_element_id
         := l_quota_pay_element_id;

         x_quota_pay_element_tbl(l_counter).quota_id
         := l_quota_id;

         x_quota_pay_element_tbl(l_counter).pay_element_type_id
         := l_pay_element_type_id;

         x_quota_pay_element_tbl(l_counter).status
         := l_status;

         x_quota_pay_element_tbl(l_counter).start_date
         := l_start_date;

         x_quota_pay_element_tbl(l_counter).end_date
         := l_end_date;

         x_quota_pay_element_tbl(l_counter).quota_name
         := l_quota_name;

         x_quota_pay_element_tbl(l_counter).pay_element_name
         := l_element_name;

        x_quota_pay_element_tbl(l_counter).pay_start_date
         := l_e_start_date;

        x_quota_pay_element_tbl(l_counter).pay_end_date
         := l_e_end_Date;

     END IF;

     l_counter := l_counter + 1;

     END LOOP;
     CLOSE quota_cur;

     x_loading_status := 'SELECTED';

     -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
 FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_quota_pay_element;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Get_quota_pay_element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data   ,
      p_encoded => FND_API.G_FALSE
      );
      WHEN OTHERS THEN
      ROLLBACK TO  Get_quota_pay_element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
END  Get_quota_pay_element;

END CN_QUOTA_PAY_ELEMENTS_PVT ;

/
