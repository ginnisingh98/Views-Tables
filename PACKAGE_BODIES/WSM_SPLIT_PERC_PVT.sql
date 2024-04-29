--------------------------------------------------------
--  DDL for Package Body WSM_SPLIT_PERC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_SPLIT_PERC_PVT" AS
/* $Header: WSMCOSPB.pls 115.3 2004/05/27 07:49:02 mprathap noship $ */

 /*---------------------------------------------------------------------------+
 | Procedure to insert a row in the split percentages table for a given	      |
 | (co-product,co product group, effective date, disable date) 		      |
 +---------------------------------------------------------------------------*/
PROCEDURE insert_row(x_err_code 		OUT NOCOPY NUMBER,
   	    	     x_err_msg                  OUT NOCOPY VARCHAR2,
		     p_co_product_id  		IN NUMBER,
		     p_co_product_group_id	IN NUMBER,
		     p_organization_id		IN NUMBER,
		     p_revision			IN VARCHAR2,
		     p_split			IN NUMBER,
		     p_primary_flag		IN VARCHAR2,
		     p_effectivity_date		IN DATE,
		     p_disable_date		IN DATE,
		     p_creation_date		IN DATE,
		     p_created_by 		IN NUMBER,
		     p_last_update_date		IN DATE,
		     p_last_updated_by 		IN NUMBER,
		     p_last_update_login	IN NUMBER     DEFAULT NULL,
		     p_attribute_category	IN VARCHAR2   DEFAULT NULL,
		     p_attribute1		IN VARCHAR2   DEFAULT NULL,
		     p_attribute2		IN VARCHAR2   DEFAULT NULL,
		     p_attribute3		IN VARCHAR2   DEFAULT NULL,
		     p_attribute4		IN VARCHAR2   DEFAULT NULL,
		     p_attribute5		IN VARCHAR2   DEFAULT NULL,
		     p_attribute6		IN VARCHAR2   DEFAULT NULL,
		     p_attribute7		IN VARCHAR2   DEFAULT NULL,
		     p_attribute8		IN VARCHAR2   DEFAULT NULL,
		     p_attribute9		IN VARCHAR2   DEFAULT NULL,
		     p_attribute10		IN VARCHAR2   DEFAULT NULL,
		     p_attribute11		IN VARCHAR2   DEFAULT NULL,
		     p_attribute12		IN VARCHAR2   DEFAULT NULL,
		     p_attribute13		IN VARCHAR2   DEFAULT NULL,
		     p_attribute14		IN VARCHAR2   DEFAULT NULL,
		     p_attribute15		IN VARCHAR2   DEFAULT NULL,
		     p_request_id               IN NUMBER     DEFAULT NULL,
                     p_program_application_id   IN NUMBER     DEFAULT NULL,
                     p_program_id               IN NUMBER     DEFAULT NULL,
                     p_program_update_date      IN DATE       DEFAULT NULL
		     )  IS

BEGIN

  x_err_code := 0;
  x_err_msg  := NULL;

  insert into WSM_COPRODUCT_SPLIT_PERC
  (
	CO_PRODUCT_GROUP_ID,
	CO_PRODUCT_ID,
	ORGANIZATION_ID,
	REVISION,
	SPLIT,
	PRIMARY_FLAG,
	EFFECTIVITY_DATE,
	DISABLE_DATE,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE
   )
   values
   (
	p_co_product_group_id,
	p_co_product_id,
	p_organization_id,
	p_revision,
	p_split,
	p_primary_flag,
        p_effectivity_date,
	p_disable_date,
	p_creation_date,
	p_created_by,
	p_last_update_date,
	p_last_updated_by ,
	p_last_update_login,
	p_attribute_category,
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_attribute11,
	p_attribute12,
	p_attribute13,
	p_attribute14,
	p_attribute15,
	p_request_id,
        p_program_application_id,
        p_program_id,
        p_program_update_date
    );

EXCEPTION
    WHEN OTHERS THEN
      x_err_code:= -1;
      x_err_msg := 'WSM_SPLIT_PERC_PVT.insert_row :' || SQLCODE || '  :' || substr(SQLERRM,1,1000);
      RETURN;
END insert_row;

 /*---------------------------------------------------------------------------+
 | Procedure to update a row in the split percentages table 		      |
 +---------------------------------------------------------------------------*/

PROCEDURE update_row(x_err_code 		OUT NOCOPY NUMBER,
		     x_err_msg                  OUT NOCOPY VARCHAR2,
		     p_rowid                    IN VARCHAR2,
		     p_co_product_id  		IN NUMBER,
		     p_co_product_group_id	IN NUMBER,
		     p_organization_id		IN NUMBER,
		     p_revision			IN VARCHAR2,
		     p_split			IN NUMBER,
		     p_primary_flag		IN VARCHAR2,
		     p_effectivity_date		IN DATE,
		     p_disable_date		IN DATE,
		     p_creation_date		IN DATE,
		     p_created_by 		IN NUMBER,
		     p_last_update_date		IN DATE,
		     p_last_updated_by 		IN NUMBER,
		     p_last_update_login	IN NUMBER,
		     p_attribute_category	IN VARCHAR2,
		     p_attribute1		IN VARCHAR2,
		     p_attribute2		IN VARCHAR2,
		     p_attribute3		IN VARCHAR2,
		     p_attribute4		IN VARCHAR2,
		     p_attribute5		IN VARCHAR2,
		     p_attribute6		IN VARCHAR2,
		     p_attribute7		IN VARCHAR2,
		     p_attribute8		IN VARCHAR2,
		     p_attribute9		IN VARCHAR2,
		     p_attribute10		IN VARCHAR2,
		     p_attribute11		IN VARCHAR2,
		     p_attribute12		IN VARCHAR2,
		     p_attribute13		IN VARCHAR2,
		     p_attribute14		IN VARCHAR2,
		     p_attribute15		IN VARCHAR2,
		     p_request_id               IN NUMBER,
                     p_program_application_id   IN NUMBER,
                     p_program_id               IN NUMBER,
                     p_program_update_date      IN DATE
		     )  IS
BEGIN

  x_err_code := 0;
  x_err_msg  := NULL;

  UPDATE WSM_COPRODUCT_SPLIT_PERC
  SET
        CO_PRODUCT_GROUP_ID     =	p_co_product_group_id,
        CO_PRODUCT_ID		=	p_co_product_id,
	ORGANIZATION_ID		=	p_organization_id,
	REVISION		=	p_revision,
	SPLIT			=	p_split,
	PRIMARY_FLAG		=	p_primary_flag,
	EFFECTIVITY_DATE	=	p_effectivity_date,
	DISABLE_DATE		=	p_disable_date,
	CREATION_DATE		=	p_creation_date,
	CREATED_BY		=	p_created_by,
	LAST_UPDATE_DATE	=	p_last_update_date,
	LAST_UPDATED_BY		=	p_last_updated_by,
	LAST_UPDATE_LOGIN	=	p_last_update_login,
	ATTRIBUTE_CATEGORY	=	p_attribute_category,
	ATTRIBUTE1		=	p_attribute1,
	ATTRIBUTE2		=	p_attribute2,
	ATTRIBUTE3		=	p_attribute3,
	ATTRIBUTE4		=	p_attribute4,
	ATTRIBUTE5		=	p_attribute5,
	ATTRIBUTE6		=	p_attribute6,
	ATTRIBUTE7		=	p_attribute7,
	ATTRIBUTE8		=	p_attribute8,
	ATTRIBUTE9		=	p_attribute9,
	ATTRIBUTE10		=	p_attribute10,
	ATTRIBUTE11		=	p_attribute11,
	ATTRIBUTE12		=	p_attribute12,
	ATTRIBUTE13		=	p_attribute13,
	ATTRIBUTE14		=	p_attribute14,
	ATTRIBUTE15		=	p_attribute15,
	REQUEST_ID		=	p_request_id,
	PROGRAM_APPLICATION_ID	=	p_program_application_id,
	PROGRAM_ID		=	p_program_id,
	PROGRAM_UPDATE_DATE	=	p_program_update_date
   WHERE rowid = p_rowid;

EXCEPTION
  WHEN OTHERS THEN
    x_err_code := -1;
    x_err_msg  := 'WSM_SPLIT_PERC_PVT.update_row :' || SQLCODE || '  :' || substr(SQLERRM,1,1000);
    RETURN;

END update_row;

 /*---------------------------------------------------------------------------+
 | Lock row procedure							      |
 |									      |
 +---------------------------------------------------------------------------*/

PROCEDURE lock_row( x_err_code 		OUT NOCOPY NUMBER,
		     x_err_msg                  OUT NOCOPY VARCHAR2,
		     p_rowid                    IN VARCHAR2,
		     p_co_product_id  		IN NUMBER,
		     p_co_product_group_id	IN NUMBER,
		     p_organization_id		IN NUMBER,
		     p_revision			IN VARCHAR2,
		     p_split			IN NUMBER,
		     p_primary_flag		IN VARCHAR2,
		     p_effectivity_date		IN DATE,
		     p_disable_date		IN DATE,
		     p_attribute_category	IN VARCHAR2,
		     p_attribute1		IN VARCHAR2,
		     p_attribute2		IN VARCHAR2,
		     p_attribute3		IN VARCHAR2,
		     p_attribute4		IN VARCHAR2,
		     p_attribute5		IN VARCHAR2,
		     p_attribute6		IN VARCHAR2,
		     p_attribute7		IN VARCHAR2,
		     p_attribute8		IN VARCHAR2,
		     p_attribute9		IN VARCHAR2,
		     p_attribute10		IN VARCHAR2,
		     p_attribute11		IN VARCHAR2,
		     p_attribute12		IN VARCHAR2,
		     p_attribute13		IN VARCHAR2,
		     p_attribute14		IN VARCHAR2,
		     p_attribute15		IN VARCHAR2
		     ) IS

  CURSOR C IS
        SELECT *
        FROM   WSM_COPRODUCT_SPLIT_PERC
        WHERE  rowid = p_rowid
        FOR UPDATE of co_product_id NOWAIT;

  l_rec C%ROWTYPE;

BEGIN

    x_err_code := 0;
    x_err_msg  := NULL;

    OPEN C;
    FETCH C INTO l_rec;

    IF (C%NOTFOUND) THEN

      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      x_err_code := -1;
      x_err_msg  := FND_MESSAGE.GET;
      RETURN;

    END IF;
    CLOSE C;

     IF  (    (l_rec.co_product_group_id    =  p_co_product_group_id)
     	  AND (l_rec.co_product_id          =  p_co_product_id)
	  AND (l_rec.organization_id        =  p_organization_id)
	  AND (l_rec.primary_flag           =  p_primary_flag)
	  AND (l_rec.split	            =  p_split)
	  AND (l_rec.revision		    =  p_revision)
	  AND (   (l_rec.attribute_category =  p_Attribute_Category)
                OR (    (l_rec.attribute_category IS NULL)
                    AND (p_Attribute_Category IS NULL)))
           AND (   (l_rec.attribute1 =  p_Attribute1)
                OR (    (l_rec.attribute1 IS NULL)
                    AND (p_Attribute1 IS NULL)))
           AND (   (l_rec.attribute2 =  p_Attribute2)
                OR (    (l_rec.attribute2 IS NULL)
                    AND (p_Attribute2 IS NULL)))
           AND (   (l_rec.attribute3 =  p_Attribute3)
                OR (    (l_rec.attribute3 IS NULL)
                    AND (p_Attribute3 IS NULL)))
           AND (   (l_rec.attribute4 =  p_Attribute4)
                OR (    (l_rec.attribute4 IS NULL)
                    AND (p_Attribute4 IS NULL)))
           AND (   (l_rec.attribute5 =  p_Attribute5)
                OR (    (l_rec.attribute5 IS NULL)
                    AND (p_Attribute5 IS NULL)))
           AND (   (l_rec.attribute6 =  p_Attribute6)
                OR (    (l_rec.attribute6 IS NULL)
                    AND (p_Attribute6 IS NULL)))
           AND (   (l_rec.attribute7 =  p_Attribute7)
                OR (    (l_rec.attribute7 IS NULL)
                    AND (p_Attribute7 IS NULL)))
           AND (   (l_rec.attribute8 =  p_Attribute8)
                OR (    (l_rec.attribute8 IS NULL)
                    AND (p_Attribute8 IS NULL)))
           AND (   (l_rec.attribute9 =  p_Attribute9)
                OR (    (l_rec.attribute9 IS NULL)
                    AND (p_Attribute9 IS NULL)))
           AND (   (l_rec.attribute10 =  p_Attribute10)
                OR (    (l_rec.attribute10 IS NULL)
                    AND (p_Attribute10 IS NULL)))
           AND (   (l_rec.attribute11 =  p_Attribute11)
                OR (    (l_rec.attribute11 IS NULL)
                    AND (p_Attribute11 IS NULL)))
           AND (   (l_rec.attribute12 =  p_Attribute12)
                OR (    (l_rec.attribute12 IS NULL)
                    AND (p_Attribute12 IS NULL)))
           AND (   (l_rec.attribute13 =  p_Attribute13)
                OR (    (l_rec.attribute13 IS NULL)
                    AND (p_Attribute13 IS NULL)))
           AND (   (l_rec.attribute14 =  p_Attribute14)
                OR (    (l_rec.attribute14 IS NULL)
                    AND (p_Attribute14 IS NULL)))
           AND (   (l_rec.attribute15 =  p_Attribute15)
                OR (    (l_rec.attribute15 IS NULL)
                    AND (p_Attribute15 IS NULL)))
      ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      x_err_code := -1;
      x_err_msg  := FND_MESSAGE.GET;
      RETURN;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_err_code := -1;
    x_err_msg  := 'WSM_SPLIT_PERC_PVT.lock_row :' || SQLCODE || '  :' || substr(SQLERRM,1,1000);
    RETURN;
END lock_row;

 /*---------------------------------------------------------------------------+
 | Procedure to delete all the entries corresponding to a (co product id,     |
 | co product group id) pair in  the split percentages table 		      |
 +---------------------------------------------------------------------------*/

PROCEDURE delete_row(   x_err_code		OUT NOCOPY NUMBER,
   			x_err_msg		OUT NOCOPY VARCHAR2,
   			p_co_product_id  	IN NUMBER,
		     	p_co_product_group_id	IN NUMBER,
			p_organization_id	IN NUMBER
			) IS
BEGIN

  x_err_code := 0;
  x_err_msg  := NULL;

  DELETE FROM WSM_COPRODUCT_SPLIT_PERC
  WHERE co_product_id       = p_co_product_id
  AND   co_product_group_id = p_co_product_group_id
  AND   organization_id     = p_organization_id;

EXCEPTION
  WHEN OTHERS THEN
    x_err_code:= -1;
    x_err_msg := 'WSM_SPLIT_PERC_PVT.delete_row :' || SQLCODE || '  :' || substr(SQLERRM,1,1000);
    RETURN;
END delete_row;

 /*---------------------------------------------------------------------------+
 | Procedure to delete all the records pertaining to a co product group id in |
 | the split percentages table						      |
 +---------------------------------------------------------------------------*/
PROCEDURE delete_all_range(x_err_code                OUT NOCOPY NUMBER,
			   x_err_msg	             OUT NOCOPY VARCHAR2,
			   p_organization_id   	     IN NUMBER,
			   p_co_product_group_id     IN NUMBER) IS
BEGIN

  x_err_code := 0;
  x_err_msg  := NULL;

  DELETE FROM WSM_COPRODUCT_SPLIT_PERC
  WHERE co_product_group_id = p_co_product_group_id
  AND   organization_id     = p_organization_id;

EXCEPTION
  WHEN OTHERS THEN
    x_err_code:= -1;
    x_err_msg := 'WSM_SPLIT_PERC_PVT.delete_all_range :' || SQLCODE || '  :' || substr(SQLERRM,1,1000);
    RETURN;
END delete_all_range;


 /*---------------------------------------------------------------------------+
 | Procedure to ensure that that no two ranges are overlapping in the time    |
 | frame. Called immediately after inserting a new split eff. range           |
 +---------------------------------------------------------------------------*/
PROCEDURE process_records ( l_co_product_gr_id  IN  NUMBER,
         		    from_eff_dt         IN  DATE,
			    to_eff_dt           IN  DATE,
			    x_err_code          OUT NOCOPY NUMBER,
			    x_err_msg		OUT NOCOPY VARCHAR2) IS
  h_eff_date DATE;    /*Effective date of the range in which from_eff_dt falls*/
  h_disable_date DATE; /*Disable date of the range in which to_eff_dt falls*/
  intersect_exists NUMBER := 0;
  stmt_num NUMBER;

  /* for debug purposes..*/
  l_debug  varchar2(200);

BEGIN

     x_err_code := 0;
     x_err_msg  := NULL;

     delete from wsm_coproduct_split_perc
     where co_product_group_id = l_co_product_gr_id
     and ( (effectivity_date >= from_eff_dt  and
              ((disable_date is not null  and  disable_date < nvl(to_eff_dt,disable_date+1))
              OR
              ((disable_date is NULL) and (to_eff_dt is NULL) and effectivity_date > from_eff_dt))
            )
            OR
            (effectivity_date > from_eff_dt and
              (disable_date is not null and disable_date <= nvl(to_eff_dt,disable_date+1))
            )
          );

     /*Look for following 2 mutually exclusive possibilities:
               1.New range entered is a sub set of existing effective range.
               2.New range is intersecting 1/2 existing eff ranges.*/


     stmt_num := 10;

     select max(effectivity_date)
     into h_eff_date
     from wsm_coproduct_split_perc
     where co_product_group_id = l_co_product_gr_id
     and  effectivity_date <= from_eff_dt
     and  not ( effectivity_date = from_eff_dt
                and
                (
                  (disable_date is null and to_eff_dt is null)
                   or
                   (disable_date=nvl(to_eff_dt,disable_date + 1))
                )
              );


     h_disable_date := null;
     intersect_exists := 0;

     IF to_eff_dt IS NOT NULL THEN

        /*   D1------------------------> D10
	           D5------------------> D10  ( new record .. no overlap ) */

        stmt_num := 20;
  	select min(disable_date)
	into h_disable_date
	from wsm_coproduct_split_perc
	where co_product_group_id = l_co_product_gr_id
	and   nvl(disable_date,to_eff_dt+1) >= to_eff_dt
	and   not (effectivity_date = from_eff_dt  and  nvl(disable_date,to_eff_dt+1) = to_eff_dt);


	--If  the following SQL selects a record, it is Possibility 1
	--  Existing range is D10 ---------  D30 -----------D40
	-- new range is            D15-- D25

     	BEGIN

		/* if D10-------------> D20 ------> D22-----> D24 -----------> D25 --------------------> null
		                        D20 --------------------------------------------> D35  ( again no intersect)
                       D15 ------------------------------------------> D25 ( again no intersect )
                       D15 ---------------------------------------------------------------------> null ( NO INTERSECT )
                                                                                D35 --------------> NULL ( NO INTERSECT )

                                     D21 --------------------------------------------> D35 ( NO intersect )
                                     D21 ----------------------> D27 ( NO INTERSECT )

                                                                                     D35 -------> D50 ( INTERSECT )
                 D5 --------> D12 ( INTERSECT )
                          */


		stmt_num := 30;

		select 1
		into intersect_exists
		from wsm_coproduct_split_perc
		where co_product_group_id = l_co_product_gr_id
		and effectivity_date < from_eff_dt
		and effectivity_date <= h_eff_date
		and ((  (disable_date is not null )
                	and
			( disable_date = nvl(h_disable_date,disable_date+1) )
			)
			OR
			(
			disable_date is null and h_disable_date is null and to_eff_dt is  not null
			)
		);


	EXCEPTION
		when NO_DATA_FOUND then
			--Partial Intersection exists
			intersect_exists := 0;
		WHEN TOO_MANY_ROWS THEN
			intersect_exists := 1;
	END;

     END IF;


     if intersect_exists = 1 then
         -- Exists D1-D20. Insert D5-D10.

        IF h_eff_date <> from_eff_dt THEN

		stmt_num := 40;

		insert into wsm_coproduct_split_perc (
			co_product_group_id,
			co_product_id,
			ORGANIZATION_ID,
			CREATION_DATE,
			CREATED_BY     ,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			REVISION,
			SPLIT  ,
			EFFECTIVITY_DATE,
			DISABLE_DATE,
			PRIMARY_FLAG)
		(select co_product_group_id,
			co_product_id,
			ORGANIZATION_ID,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			REVISION,
			SPLIT,
			h_eff_date,
			from_eff_dt,
			PRIMARY_FLAG
		from   wsm_coproduct_split_perc
		where  co_product_group_id = l_co_product_gr_id
		and    effectivity_date = h_eff_date
		and    ((disable_date IS NULL and h_disable_date IS NULL) OR (disable_date IS NOT NULL AND (disable_date = nvl(h_disable_date,disable_date+1)))));
       	end if;

        if (nvl(h_disable_date,to_eff_dt+1) <> to_eff_dt) THEN

       		stmt_num := 50;

		insert into wsm_coproduct_split_perc (
			co_product_group_id,
			co_product_id,
			ORGANIZATION_ID,
			CREATION_DATE,
			CREATED_BY     ,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			REVISION,
			SPLIT  ,
			EFFECTIVITY_DATE,
			DISABLE_DATE,
			PRIMARY_FLAG)
		(select co_product_group_id,
			co_product_id,
			ORGANIZATION_ID,
			CREATION_DATE,
			CREATED_BY     ,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			REVISION,
			SPLIT,
			to_eff_dt,
			h_disable_date,
			PRIMARY_FLAG
		from   wsm_coproduct_split_perc
		where  co_product_group_id = l_co_product_gr_id
		and    ((disable_date IS NULL and h_disable_date IS NULL) OR (disable_date IS NOT NULL AND (disable_date = nvl(h_disable_date,disable_date+1))))
		and    not(effectivity_date = from_eff_dt));


	end if;

	stmt_num := 60;

	delete from wsm_coproduct_split_perc
	where co_product_group_id = l_co_product_gr_id
	and effectivity_date = h_eff_date
	and ((disable_date IS NULL and h_disable_date IS NULL) OR (disable_date IS NOT NULL AND (disable_date = nvl(h_disable_date,disable_date+1))));
	--End of possibility 1.

	return;

     end if;

     /* Now, need to update D15-D20 period as D16-D20*/
     --Possibility 2
     stmt_num := 70;

     IF to_eff_dt is not null THEN

     	update wsm_coproduct_split_perc
	set effectivity_date = to_eff_dt
	where co_product_group_id = l_co_product_gr_id
	and  ((disable_date IS NULL and h_disable_date IS NULL) OR (disable_date IS NOT NULL AND (disable_date = nvl(h_disable_date,disable_date+1))));

     end if;


     /* Suppose we changed dates from D7-D16 instead of D5-D16, we need to
        update D5-D10 to D5-D7*/

     stmt_num := 80;

     update wsm_coproduct_split_perc
     set disable_date = from_eff_dt
     where co_product_group_id = l_co_product_gr_id
     and   effectivity_date = h_eff_date;

 EXCEPTION
  WHEN OTHERS THEN
    x_err_code := -1;
    x_err_msg  := 'WSM_SPLIT_PERC_PVT .process_records : stmt : ' || stmt_num || '  ' || SQLCODE || '  :' || substr(SQLERRM,1,1000);
    RETURN;
end process_records;

 /*---------------------------------------------------------------------------+
 | Procdure to check if the update of comp. eff/ disable date will cause      |
 | the deletion of any existent ranges					      |
 +---------------------------------------------------------------------------*/

 /* This procedure is not used as comp. eff./diable date will not be related to the
    co product eff/disable dates */

FUNCTION validate_range (p_co_product_group_id  IN NUMBER,
 			 p_organization_id      IN NUMBER,
			 p_effectivity_date     IN DATE,
			 p_disable_date	  IN DATE)  RETURN NUMBER IS

  l_retval  NUMBER:=0;
  l_num     NUMBER:=0;

BEGIN
  -- Determine if any of the ranges have a lesser effectivity dates.

  BEGIN
    select 1
    into l_num
    from WSM_COPRODUCT_SPLIT_PERC
    where organization_id  =  p_organization_id
    and   co_product_group_id = p_co_product_group_id
    and   disable_date is not NULL
    and   disable_date <= p_effectivity_date;


    l_retval:=l_retval+1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    WHEN TOO_MANY_ROWS THEN
      l_num := 1;
      l_retval := l_retval + 1;
  END;

  -- Determine if any of the ranges has a higher effectivity dates.

  BEGIN
    IF p_disable_date is NOT NULL THEN
    	select 1
	into l_num
	from WSM_COPRODUCT_SPLIT_PERC
	where organization_id  =  p_organization_id
	and   co_product_group_id = p_co_product_group_id
	and   effectivity_date >= p_disable_date;

       	l_retval:=l_retval+2;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    WHEN TOO_MANY_ROWS THEN
       l_num :=  1;
       	l_retval:=l_retval+2;
  END;

  RETURN l_retval;
END validate_range;

 /*---------------------------------------------------------------------------+
 | Procdure to update/delete any existent ranges that would be affected by the|
 | the update of comp. eff. date/ disable date  			      |
 +---------------------------------------------------------------------------*/

 /* This procedure is not used as comp. eff./diable date will not be related to the
    co product eff/disable dates */

PROCEDURE update_split_range(x_err_code 		OUT NOCOPY NUMBER,
			     x_err_msg  		OUT NOCOPY VARCHAR2,
			     p_organization_id          IN NUMBER,
			     p_co_product_group_id      IN NUMBER,
			     p_effectivity_date		IN DATE,
			     p_disable_date		IN DATE,
			     p_update_range             IN NUMBER
			     ) IS

  l_num NUMBER:=0;
BEGIN

  -- Indicates that effe. date will result in some deletion
  IF p_update_range IN (1,3) THEN
  	-- delete any range which has the disable date less than or equal to the
	-- new effectivity date
	DELETE FROM WSM_COPRODUCT_SPLIT_PERC
	WHERE  organization_id = p_organization_id
	AND    co_product_group_id = p_co_product_group_id
	AND    disable_date is NOT NULL
	AND    disable_date <= p_effectivity_date;
  END IF;

  -- Update the effect. date of the range that has the effec. date less than the
  -- new effectivity date
  UPDATE WSM_COPRODUCT_SPLIT_PERC
  SET effectivity_date = p_effectivity_date
  WHERE organization_id = p_organization_id
  AND   co_product_group_id = p_co_product_group_id
  AND   effectivity_date < p_effectivity_date;

  -- Indicates that some range has to be deleted due to the new disable date..
  IF p_update_range IN (2,3) THEN
  	-- delete any range which has the effective date greater than or equal
	-- to the new disable date..
	DELETE
	FROM WSM_COPRODUCT_SPLIT_PERC
	WHERE  organization_id = p_organization_id
	AND    co_product_group_id = p_co_product_group_id
	AND    effectivity_date >= NVL(p_disable_date,effectivity_date-1);

  END IF;

  BEGIN
  	-- check if any NULL disable date exist..
        l_num := 0;

	select 1
	into l_num
	from WSM_COPRODUCT_SPLIT_PERC
	WHERE  organization_id = p_organization_id
	AND    co_product_group_id = p_co_product_group_id
	AND    disable_date IS NULL;

  EXCEPTION
       	WHEN NO_DATA_FOUND THEN
		l_num := 0;

	WHEN TOO_MANY_ROWS THEN
		l_num := 1;
  END;

  IF l_num = 1 THEN
	-- disable date has been changed from NULL to a non-null value...
	-- so update all records with NULL disable date.
	IF p_disable_date IS NOT NULL THEN
		UPDATE WSM_COPRODUCT_SPLIT_PERC
		SET disable_date = p_disable_date
		WHERE  organization_id = p_organization_id
		AND    co_product_group_id = p_co_product_group_id
		AND    disable_date is NULL;

        END IF;
  ELSIF l_num = 0 THEN

	-- No records exist with NULL disable date

	UPDATE WSM_COPRODUCT_SPLIT_PERC
	SET disable_date = p_disable_date
	WHERE  organization_id = p_organization_id
	AND    co_product_group_id = p_co_product_group_id
	AND    disable_date IN ( SELECT MAX(disable_date)
	 			 FROM WSM_COPRODUCT_SPLIT_PERC
				 WHERE  organization_id = p_organization_id
				 AND    co_product_group_id = p_co_product_group_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_err_code := -1;
    x_err_msg  := 'WSM_SPLIT_PERC_PVT.update_split_range : ' || SQLCODE || substr(SQLERRM,1,1000);
    RETURN;
END update_split_range;

 /*---------------------------------------------------------------------------+
 | Procedure to insert a co-product in all ranges of a co-product group id    |
 | with split perc 0% in case of sec. co-product and 100% in case of          |
 | primary co-product							      |
 +---------------------------------------------------------------------------*/

PROCEDURE insert_co_product_range(x_err_code 		  OUT NOCOPY NUMBER,
 				   x_err_msg		  OUT NOCOPY VARCHAR2,
 				   p_co_product_group_id  IN NUMBER,
				   p_co_product_id	  IN NUMBER,
				   p_revision		  IN VARCHAR2,
				   p_split      	  IN NUMBER,
				   p_primary_flag 	  IN VARCHAR2,
 			   	   p_organization_id      IN NUMBER,
				   p_effectivity_date     IN DATE,
				   p_disable_date	  IN DATE,
				   p_creation_date	  IN DATE,
				   p_created_by 	  IN NUMBER,
				   p_last_update_date	  IN DATE,
				   p_last_updated_by 	  IN NUMBER
				   ) IS
  CURSOR range_cursor IS select distinct effectivity_date,disable_date
	 		 from WSM_COPRODUCT_SPLIT_PERC
			 where co_product_group_id= p_co_product_group_id;

  l_num 	   NUMBER:=0;

  l_err_code       NUMBER:=0;
  l_err_msg        VARCHAR2(2000);


BEGIN
  /*---------------------------------------------------------------+
  | first check if any range exist for this co-product-group_id    |
  +---------------------------------------------------------------*/

  BEGIN
  	select 1
	into l_num
	from WSM_COPRODUCT_SPLIT_PERC
	WHERE co_product_group_id = p_co_product_group_id ;

  EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  l_num :=0;
	WHEN TOO_MANY_ROWS THEN
	  l_num := 1;
  END;

  /* If the value of l_num = 0 then no records exist.. use the
     value of p_effectivity_date and disable date passed... */

  IF (l_num=0) THEN
    -- insert using the date data passed
    WSM_SPLIT_PERC_PVT.insert_row(x_err_code 		 =>  l_err_code,
			        x_err_msg          	 =>  l_err_msg,
				p_co_product_id  	 =>  p_co_product_id,
		     		p_co_product_group_id    =>  p_co_product_group_id,
		    	        p_organization_id	 =>  p_organization_id,
		   	        p_revision	         =>  p_revision,
	   		        p_split			 =>  p_split,
		                p_primary_flag		 =>  p_primary_flag,
		                p_effectivity_date	 =>  p_effectivity_date,
		                p_disable_date		 =>  p_disable_date,
		                p_creation_date		 =>  p_creation_date,
		                p_created_by 		 =>  p_created_by,
		                p_last_update_date	 =>  p_last_update_date,
		                p_last_updated_by 	 =>  p_last_updated_by );
    IF l_err_code <> 0 THEN
   	  -- indicates that some error has occured....
	  x_err_code := l_err_code;
	  x_err_msg  := l_err_msg;
	  RETURN;
    END IF;
  ELSIF l_num=1 THEN
     -- Indicates that the information resides in the db for this co-product...
     -- so open the cursor and insert this data...
     SAVEPOINT date_save;
     FOR date_rec IN range_cursor LOOP
        -- get the data and call the insert procedure....
	WSM_SPLIT_PERC_PVT.insert_row(x_err_code 	 =>  l_err_code,
			        x_err_msg          	 =>  l_err_msg,
				p_co_product_id  	 =>  p_co_product_id,
		     		p_co_product_group_id    =>  p_co_product_group_id,
		    	        p_organization_id	 =>  p_organization_id,
		   	        p_revision	         =>  p_revision,
	   		        p_split			 =>  p_split,
		                p_primary_flag		 =>  p_primary_flag,
		                p_effectivity_date	 =>  date_rec.effectivity_date,
		                p_disable_date		 =>  date_rec.disable_date,
		                p_creation_date		 =>  p_creation_date,
		                p_created_by 		 =>  p_created_by,
		                p_last_update_date	 =>  p_last_update_date,
		                p_last_updated_by 	 =>  p_last_updated_by );
	 IF l_err_code <> 0 THEN
   	  	-- indicates that some error has occured....
		 ROLLBACK TO date_save;
	 	 x_err_code := l_err_code;
		 x_err_msg  := l_err_msg;
		 RETURN;
	 END IF;
     END LOOP;
     -- end of the cursor code...
  END IF;
EXCEPTION
  WHEN OTHERS THEN
      x_err_code := -1;
      x_err_msg  := 'WSM_SPLIT_PERC_PVT.insert_co_product_range : ' || SQLCODE || substr(SQLERRM,1,1000);
      RETURN;
END insert_co_product_range;

/*---------------------------------------------------------------------------+
 | Procedure to check if there is atleast one co product of a co-prod group  |
 | in the range passed that has a zero split percentage..	     	     |
 +--------------------------------------------------------------------------*/

FUNCTION check_split_perc_exists(x_err_code  	        OUT NOCOPY NUMBER,
				  x_err_msg   	        OUT NOCOPY VARCHAR2,
				  p_co_product_group_id IN NUMBER,
				  p_organization_id     IN NUMBER,
				  p_effectivity_date    IN DATE,
				  p_disable_date        IN DATE) RETURN BOOLEAN IS
  l_num NUMBER:=0;
  l_count NUMBER:=0;
BEGIN
  x_err_code := 0;
  x_err_msg := null;

  BEGIN

	select 1
	into l_num
	from WSM_COPRODUCT_SPLIT_PERC
	where organization_id = p_organization_id
	and co_product_group_id = p_co_product_group_id
	and effectivity_date = p_effectivity_date
	and ((p_disable_date is NULL and disable_date is NULL) OR (p_disable_date = disable_date))
	and split = 0;

	RETURN TRUE;

     EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN TOO_MANY_ROWS THEN
	  	RETURN TRUE;
 END;
 EXCEPTION
   WHEN OTHERS THEN
      x_err_code := -1;
      x_err_msg  := 'WSM_SPLIT_PERC_PVT.check_split_perc_exists : ' || SQLCODE || substr(SQLERRM,1,1000);
      RETURN TRUE;

END check_split_perc_exists;

 /*---------------------------------------------------------------------------+
 | Procedure to check if there is atleast one range in wich the co product    |
 | passed has a non-zero split percentage.. 				      |
 +---------------------------------------------------------------------------*/

FUNCTION check_split_perc_exists(x_err_code  	        OUT NOCOPY NUMBER,
				  x_err_msg   	        OUT NOCOPY VARCHAR2,
				  p_co_product_id       IN NUMBER,
				  p_co_product_group_id IN NUMBER,
				  p_organization_id     IN NUMBER ) RETURN BOOLEAN IS
  l_num NUMBER:=0;
  l_count NUMBER:=0;
BEGIN
  x_err_code := 0;
  x_err_msg := null;

  IF p_co_product_id IS NOT NULL THEN

    BEGIN
    	/* one more check to be done here...
	   check if it is the only one left and it is the primary.. */

	SELECT 1
	INTO l_num
	from WSM_COPRODUCT_SPLIT_PERC
	where organization_id = p_organization_id
	and co_product_group_id = p_co_product_group_id
	and co_product_id <> p_co_product_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

	 -- even though split may be more than 0..
	 -- since this is the only co-product left can go ahead with the deletion.
	  RETURN FALSE;

	WHEN  TOO_MANY_ROWS THEN
		NULL;
    END;

    BEGIN

	SELECT 1
	INTO l_num
	from WSM_COPRODUCT_SPLIT_PERC
	where organization_id = p_organization_id
	and co_product_group_id = p_co_product_group_id
	and co_product_id = p_co_product_id
	and split > 0 ;

	RETURN TRUE;

     EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN TOO_MANY_ROWS THEN
	 	RETURN TRUE;
     END;
   ELSE
        -- Indicates that the check is for the full co-product-group-id
        --- selects the max. no. of ranges in which any co-product of the
	-- given co_product_group_id has 0%
/*Bug 3647337
	select distinct max(count(*))
        into l_num
        from WSM_COPRODUCT_SPLIT_PERC
        where organization_id = p_organization_id
        and co_product_group_id = p_co_product_group_id
        and split = 0
	group by co_product_id;
*/

	-- selects the totla no. of ranges for a co_product_group_id
       /*3647337
	select count(*)
	into l_count
	from WSM_COPRODUCT_SPLIT_DATES_V
	where organization_id = p_organization_id
        and co_product_group_id = p_co_product_group_id;
       Bug 3647337*/

        --Following SQL is added for 3647337
	select min(sum(split))
	into l_num
	from WSM_COPRODUCT_SPLIT_PERC
	where organization_id = p_organization_id
        and co_product_group_id = p_co_product_group_id
        group by co_product_id;
	-- If equal then atleast one co-product has 0% split in all the ranges..
	--IF l_num=l_count THEN Bug 3647337
	IF l_num=0 THEN --Bug 3647337
	   -- Indicates that atleast one record exists with 0 in all the ranges.
	   RETURN TRUE;
	ELSE
	  RETURN FALSE;
        END IF;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_err_code := -1;
      x_err_msg  := 'WSM_SPLIT_PERC_PVT.check_split_perc_exists : ' || SQLCODE || substr(SQLERRM,1,1000);
      RETURN TRUE;

END check_split_perc_exists;

 /*---------------------------------------------------------------------------+
 | Procedure to check if a co-product group id had got only one	split 	      |
 | effectivity range							      |
 +---------------------------------------------------------------------------*/

FUNCTION check_unique_range(x_err_code  	        OUT NOCOPY NUMBER,
		             x_err_msg   	        OUT NOCOPY VARCHAR2,
			     p_co_product_group_id      IN NUMBER,
			     p_organization_id          IN NUMBER )  RETURN BOOLEAN IS

  l_num NUMBER := 0;
BEGIN
  x_err_code := 0;
  x_err_msg  := null;

  /*3647337
  SELECT count(*)
  INTO   l_num
  FROM   WSM_COPRODUCT_SPLIT_DATES_V
  where organization_id = p_organization_id
  and co_product_group_id = p_co_product_group_id;
  3647337*/
  --Following SQL is added for 3647337
  SELECT count(*)
  INTO   l_num
  FROM WSM_COPRODUCT_SPLIT_PERC
  where organization_id = p_organization_id
  and co_product_group_id = p_co_product_group_id
  group by EFFECTIVITY_DATE;

  IF l_num > 1 THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_err_code := -1;
      x_err_msg  := 'WSM_SPLIT_PERC_PVT.check_unique_range : ' || SQLCODE || substr(SQLERRM,1,1000);
      RETURN TRUE;
END check_unique_range;

 /*---------------------------------------------------------------------------+
 | Procedure to check if the new eff. range ( eff date/ disable date ) 	      |
 | will cause any existing ranges to be deleted				      |
 +---------------------------------------------------------------------------*/

FUNCTION check_any_del_range ( p_co_product_group_id  IN NUMBER,
 			       p_organization_id      IN NUMBER,
			       p_effectivity_date     IN DATE,
			       p_disable_date	  IN DATE)  RETURN NUMBER IS

  l_retval  NUMBER:=0;
  l_num     NUMBER:=0;

BEGIN

  -- Determine if any of the ranges has a higher effectivity dates.
  BEGIN
    IF p_disable_date IS NOT NULL THEN

	/* This deals with situations like
          D10 ---------> D30--------------> NULL
	  and the user is entering
	  D5 -------------> D35
       */
	SELECT 1
	INTO l_num
        FROM WSM_COPRODUCT_SPLIT_PERC
        where organization_id  =  p_organization_id
        and   co_product_group_id = p_co_product_group_id
	and   disable_date is NOT NULL
	and   effectivity_date >= p_effectivity_date
	and   disable_date<=p_disable_date;


    	l_retval:=1;
    ELSE

       /* This deals with situations like
          D10 ---------> D30
	  and the user is entering
	  D5 -------------> NULL
       */

       SELECT 1
       INTO l_num
       FROM WSM_COPRODUCT_SPLIT_PERC
       WHERE organization_id  =  p_organization_id
       and   co_product_group_id = p_co_product_group_id
       and   disable_date is NOT NULL
       and   effectivity_date >= p_effectivity_date;

       l_retval := 1;

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
     WHEN TOO_MANY_ROWS THEN
       l_retval := 1;
  END;

  RETURN l_retval;
END check_any_del_range;


 /*---------------------------------------------------------------------------+
 | Procedure to check if a range is preexisting			 	      |
 +---------------------------------------------------------------------------*/

FUNCTION check_unique(x_err_code  	        OUT NOCOPY NUMBER,
		      x_err_msg   	        OUT NOCOPY VARCHAR2,
		      p_co_product_group_id      IN NUMBER,
		      p_organization_id          IN NUMBER,
		      p_effectivity_date 	 IN DATE,
		      p_disable_date 		 IN DATE)  RETURN BOOLEAN IS

   l_num NUMBER := 0;

BEGIN
  x_err_code := 0;
  x_err_msg  := null;

  BEGIN
  	IF p_disable_date is NULL THEN

	     SELECT 1
	     INTO  l_num
	     FROM WSM_COPRODUCT_SPLIT_PERC
	     WHERE organization_id  =  p_organization_id
	     AND   co_product_group_id = p_co_product_group_id
	     AND   effectivity_date = p_effectivity_date
	     AND   disable_date IS NULL;

	     RETURN FALSE;

	ELSE

	     SELECT 1
	     INTO  l_num
	     FROM WSM_COPRODUCT_SPLIT_PERC
	     WHERE organization_id  =  p_organization_id
	     AND   co_product_group_id = p_co_product_group_id
	     AND   effectivity_date = p_effectivity_date
	     AND   disable_date = p_disable_date;

	     RETURN FALSE;

	END IF;

 EXCEPTION
      WHEN TOO_MANY_ROWS THEN
      	   RETURN FALSE; /* when multiple co-products exist in def. */

      WHEN NO_DATA_FOUND THEN
      	   RETURN TRUE;
 END;

EXCEPTION
   WHEN OTHERS THEN
      x_err_code := -1;
      x_err_msg  := 'WSM_SPLIT_PERC_PVT.check_unique : ' || SQLCODE || substr(SQLERRM,1,1000);
      RETURN TRUE;

END check_unique;

END WSM_SPLIT_PERC_PVT;

/
