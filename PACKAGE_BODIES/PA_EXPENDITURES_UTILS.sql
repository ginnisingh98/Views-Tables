--------------------------------------------------------
--  DDL for Package Body PA_EXPENDITURES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXPENDITURES_UTILS" AS
/* $Header: PAXEXUTB.pls 120.3.12010000.2 2010/02/05 20:02:20 djanaswa ship $ */

   G_Organization_id NUMBER(15);
   G_Organization_id_1 NUMBER(15);
 /* Bug No. 2487147 ; Change done for UTF8:- Changed G_Organization_Name from VARCHAR2(60) to %TYPE */
 /* G_Organization_Name VARCHAR2(60);  */
   G_Organization_Name hr_all_organization_units_tl.name%TYPE;
   G_Organization_Name_1 hr_all_organization_units_tl.name%TYPE;
   /*  Bug 3637411 : Added the following variable for buffering the Organisation Name
       in the Base Language */
   G_Organization_Name_US hr_all_organization_units.name%TYPE;
   G_Job_Id NUMBER(15);
   G_Job_Name VARCHAR2(240);

FUNCTION  GetOrgTlName ( P_Organization_Id IN NUMBER ) RETURN VARCHAR2 IS
 x_org  hr_all_organization_units_tl.name%TYPE;

BEGIN
	If P_Organization_Id is NULL THEN
		RETURN ( NULL );
        End If;
/*
	If G_Organization_Name is null OR
	   P_Organization_Id <> G_Organization_id Then
		select tl.name
		into  G_Organization_Name
                from  hr_org_units_no_join o,
                      hr_all_organization_units_tl tl
		where
                      o.organization_id(+) = P_Organization_Id
                and   o.organization_id = tl.organization_id(+)
                and ( ( tl.organization_id is null and
                        1 = 1)
                   or ( tl.organization_id is not null and
                        tl.language = userenv('LANG'))) ;

 --Bug 1777404.  Got rid of decode due to performance team request
--             and   decode(tl.organization_id,null,'1',tl.language) =
--                      decode(tl.organization_id,null,'1',userenv('LANG')) ;
--

		If G_Organization_Name IS NOT NULL Then
			G_Organization_id := P_Organization_Id;

		End If;
	End If;
*/
  -- Fix for bug : 4005004
        If G_Organization_id IS NULL then
                select tl.name
                into  G_Organization_Name
                from  hr_org_units_no_join o,
                      hr_all_organization_units_tl tl
                where
                      o.organization_id(+) = P_Organization_Id
                and   o.organization_id = tl.organization_id(+)
                and ( ( tl.organization_id is null and
                        1 = 1)
                   or ( tl.organization_id is not null and
                        tl.language = userenv('LANG'))) ;

                  G_Organization_id := P_Organization_Id;
                             x_org  := G_Organization_Name ;

        elsif  G_Organization_id  <> P_Organization_Id then
              if NVL(G_Organization_id_1, 0) <> P_Organization_Id then
                select tl.name
                into  G_Organization_Name_1
                from  hr_org_units_no_join o,
                      hr_all_organization_units_tl tl
                where
                      o.organization_id(+) = P_Organization_Id
                and   o.organization_id = tl.organization_id(+)
                and ( ( tl.organization_id is null and
                        1 = 1)
                   or ( tl.organization_id is not null and
                        tl.language = userenv('LANG'))) ;

                G_Organization_id_1 := P_Organization_Id;
                             x_org  := G_Organization_Name_1 ;

              else
               x_org  := G_Organization_Name_1 ; -- G_Organization_id_1 = P_Organization_Id

              end if;  -- end if for NVL(G_Organization_id_1, 0) <> P_Organization_Id
        else           --  G_Organization_id = P_Organization_Id

              x_org  := G_Organization_Name ;

        end if ;

--	return ( G_Organization_Name );
	return ( x_org  );

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

End GetOrgTlName;

/* Added the following function to get the Organization Name in the
   Base Language */
FUNCTION  GetOrgName ( P_Organization_Id IN NUMBER ) RETURN VARCHAR2

IS

BEGIN
	If P_Organization_Id is NULL THEN
		RETURN ( NULL );
        End If;

	If G_Organization_Name_US is null
	OR P_Organization_Id <> NVL(G_Organization_id,-99) Then /* Added nvl() for bug 4240184*/
		select name
		into   G_Organization_Name_US
                from   hr_org_units_no_join
		where  organization_id = P_Organization_Id;
           G_Organization_id := P_Organization_Id; /* Added for bug 4240184*/
	End If;

	return ( G_Organization_Name_US );

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN (NULL);
	WHEN OTHERS THEN
		RAISE;

End GetOrgName;

/* New function GET_ORG_NAME added for Bug 6450225 Start */
FUNCTION GET_ORG_NAME ( P_ORG_ID IN NUMBER , P_ORG_CTL IN VARCHAR ) RETURN VARCHAR2
IS
   X_ORG_NAME     HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE ;

BEGIN
  IF P_ORG_ID = NULL THEN
       RETURN(NULL);
  END IF;

  IF ( P_ORG_CTL = 'CC_PRVDR') THEN
    IF ( P_ORG_ID = PREV_CC_PRVDR_ORG_ID ) THEN
	 X_ORG_NAME := PREV_CC_PRVDR_ORG_NAME;
    ELSE
	PREV_CC_PRVDR_ORG_ID  := P_ORG_ID ;
	SELECT
	    TL.NAME
	  INTO
	    X_ORG_NAME
	 FROM
	  HR_ORG_UNITS_NO_JOIN O,
	  HR_ALL_ORGANIZATION_UNITS_TL TL
	 WHERE
	   O.ORGANIZATION_ID(+) = P_ORG_ID
	  AND
	    O.ORGANIZATION_ID = TL.ORGANIZATION_ID(+)
	  AND
	  ( ( TL.ORGANIZATION_ID IS NULL AND 1 = 1)
	 OR
	  ( TL.ORGANIZATION_ID IS NOT NULL AND TL.LANGUAGE = USERENV('LANG'))) ;
 	PREV_CC_PRVDR_ORG_NAME := X_ORG_NAME ;
    END IF;

  ELSIF ( P_ORG_CTL = 'CC_RECVR') THEN
    IF ( P_ORG_ID = PREV_CC_RECVR_ORG_ID ) THEN
	 X_ORG_NAME := PREV_CC_RECVR_ORG_NAME;
    ELSE
	PREV_CC_RECVR_ORG_ID  := P_ORG_ID ;
	SELECT
	    TL.NAME
	  INTO
	    X_ORG_NAME
	 FROM
	  HR_ORG_UNITS_NO_JOIN O,
	  HR_ALL_ORGANIZATION_UNITS_TL TL
	 WHERE
	   O.ORGANIZATION_ID(+) = P_ORG_ID
	  AND
	    O.ORGANIZATION_ID = TL.ORGANIZATION_ID(+)
	  AND
	  ( ( TL.ORGANIZATION_ID IS NULL AND 1 = 1)
	 OR
	  ( TL.ORGANIZATION_ID IS NOT NULL AND TL.LANGUAGE = USERENV('LANG'))) ;
 	PREV_CC_RECVR_ORG_NAME := X_ORG_NAME ;
    END IF;

  ELSIF ( P_ORG_CTL = 'PRVDR') THEN
    IF ( P_ORG_ID = PREV_PRVDR_ORG_ID ) THEN
	 X_ORG_NAME := PREV_PRVDR_ORG_NAME;
    ELSE
	PREV_PRVDR_ORG_ID  := P_ORG_ID ;
	SELECT
	    TL.NAME
	  INTO
	    X_ORG_NAME
	 FROM
	  HR_ORG_UNITS_NO_JOIN O,
	  HR_ALL_ORGANIZATION_UNITS_TL TL
	 WHERE
	   O.ORGANIZATION_ID(+) = P_ORG_ID
	  AND
	    O.ORGANIZATION_ID = TL.ORGANIZATION_ID(+)
	  AND
	  ( ( TL.ORGANIZATION_ID IS NULL AND 1 = 1)
	 OR
	  ( TL.ORGANIZATION_ID IS NOT NULL AND TL.LANGUAGE = USERENV('LANG'))) ;
 	PREV_PRVDR_ORG_NAME := X_ORG_NAME ;
    END IF;

  ELSIF ( P_ORG_CTL = 'RECVR') THEN
    IF ( P_ORG_ID = PREV_RECVR_ORG_ID ) THEN
	 X_ORG_NAME := PREV_RECVR_ORG_NAME;
    ELSE
	PREV_RECVR_ORG_ID  := P_ORG_ID ;
	SELECT
	    TL.NAME
	  INTO
	    X_ORG_NAME
	 FROM
	  HR_ORG_UNITS_NO_JOIN O,
	  HR_ALL_ORGANIZATION_UNITS_TL TL
	 WHERE
	   O.ORGANIZATION_ID(+) = P_ORG_ID
	  AND
	    O.ORGANIZATION_ID = TL.ORGANIZATION_ID(+)
	  AND
	  ( ( TL.ORGANIZATION_ID IS NULL AND 1 = 1)
	 OR
	  ( TL.ORGANIZATION_ID IS NOT NULL AND TL.LANGUAGE = USERENV('LANG'))) ;
 	PREV_RECVR_ORG_NAME := X_ORG_NAME ;
    END IF;

  ELSIF ( P_ORG_CTL = 'NLR') THEN
    IF ( P_ORG_ID = PREV_NLR_ORG_ID ) THEN
	 X_ORG_NAME := PREV_NLR_ORG_NAME;
    ELSE
	PREV_NLR_ORG_ID  := P_ORG_ID ;
	SELECT
	    TL.NAME
	  INTO
	    X_ORG_NAME
	 FROM
	  HR_ORG_UNITS_NO_JOIN O,
	  HR_ALL_ORGANIZATION_UNITS_TL TL
	 WHERE
	   O.ORGANIZATION_ID(+) = P_ORG_ID
	  AND
	    O.ORGANIZATION_ID = TL.ORGANIZATION_ID(+)
	  AND
	  ( ( TL.ORGANIZATION_ID IS NULL AND 1 = 1)
	 OR
	  ( TL.ORGANIZATION_ID IS NOT NULL AND TL.LANGUAGE = USERENV('LANG'))) ;
 	PREV_NLR_ORG_NAME := X_ORG_NAME ;
    END IF;
  END IF;

  RETURN (X_ORG_NAME);

EXCEPTION

    WHEN  OTHERS  THEN
	  PREV_CC_PRVDR_ORG_NAME     := NULL;
	  PREV_CC_RECVR_ORG_NAME     := NULL;
	  PREV_PRVDR_ORG_NAME    := NULL;
	  PREV_RECVR_ORG_NAME     := NULL;
	  PREV_NLR_ORG_NAME    := NULL;
          RAISE  ;

  END GET_ORG_NAME;
/* New function GET_ORG_NAME added for Bug 6450225 End */
FUNCTION GetJobName ( P_Job_Id IN NUMBER ) RETURN VARCHAR2

IS

BEGIN

	If P_Job_id is NULL THEN
		return ( NULL );
	End If;
	If G_Job_Name is null OR
	   P_Job_Id <> G_Job_Id Then

		select name
		into G_job_name
		from per_jobs
		where job_id = p_job_id;

                If G_Job_Name is not null then
                	G_job_id := p_job_id;
        	End If;

	End If;

	return ( G_Job_Name );

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END GetJobName;

--------------------------------------------------------------

--  PROCEDURE
--		Check_Expenditure_Type
--  PURPOSE
--              This procedure validates if the given
--              Expenditure Type is valid on the given date.
--  HISTORY
--   21-NOV-2000      P. Bandla       Created
PROCEDURE Check_Expenditure_Type(
		p_expenditure_type   IN VARCHAR2,
		p_date               IN DATE,
		x_valid		         OUT NOCOPY VARCHAR2,
		x_return_status      OUT NOCOPY VARCHAR2,
        x_error_message_code OUT NOCOPY VARCHAR2) IS

BEGIN

	IF (PA_UTILS.CheckExpTypeActive(X_expenditure_type =>p_expenditure_type, X_date   =>   p_date )) THEN

		x_valid := 'Y';
		x_return_status := FND_API.G_RET_STS_SUCCESS;

	ELSE

		x_valid := 'N';
		x_return_status := FND_API.G_RET_STS_ERROR;
	    x_error_message_code := 'PA_EXPTYPE_INVALID';

	END IF;

EXCEPTION
	--WHEN NO_DATA_FOUND THEN
          --x_return_status := FND_API.G_RET_STS_ERROR;
          --x_error_message_code := 'PA_EXPTYPE_INVALID';
	WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_error_message_code := NULL;
      x_valid  := 'N';

END Check_Expenditure_Type;

--  PROCEDURE
--		Check_Exp_Type_Class_Code
--  PURPOSE
--              This procedure does the following
--              If meaning is passed converts it to the id
--              If code is passed,
--              based on the check_id_flag validates it
--  HISTORY
--   21-NOV-2000      P. Bandla       Created
PROCEDURE Check_Exp_Type_Class_Code(
			p_sys_link_func		 IN	VARCHAR2,
			p_exp_meaning		 IN	VARCHAR2,
			p_check_id_flag		 IN	VARCHAR2,
			x_sys_link_func		 OUT NOCOPY VARCHAR2,
			x_return_status		 OUT NOCOPY VARCHAR2,
			x_error_message_code OUT NOCOPY VARCHAR2 )
IS

BEGIN

	IF p_sys_link_func IS NOT NULL THEN

		IF p_check_id_flag = 'Y' THEN

			SELECT function
		    INTO   x_sys_link_func
		    FROM   pa_system_linkages
		    WHERE  function = p_sys_link_func;

	    ELSE

			x_sys_link_func := p_sys_link_func;

		END IF;

    ELSE

		SELECT function
		INTO   x_sys_link_func
		FROM   pa_system_linkages
		WHERE  meaning = p_exp_meaning;

    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    x_error_message_code := 'PA_EXPCODE_INVALID';
        x_sys_link_func := Null;
    WHEN TOO_MANY_ROWS THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    x_error_message_code := 'PA_EXPCODE_INVALID';
        x_sys_link_func := Null;
    WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_error_message_code := Null;
        x_sys_link_func := Null;

END Check_Exp_Type_Class_Code;

--  PROCEDURE
--		Check_Exp_Type_Sys_Link_Combo
--  PURPOSE
--              This procedure validates the combination
--              of expenditure type and system linkage function
--  HISTORY
--   21-NOV-2000      P. Bandla       Created
PROCEDURE Check_Exp_Type_Sys_Link_Combo(
			p_exp_type		     IN  VARCHAR2,
			p_ei_date		     IN  DATE,
			p_sys_link_func		 IN  VARCHAR2,
			x_valid			     OUT NOCOPY VARCHAR2,
			x_return_status		 OUT NOCOPY VARCHAR2,
			x_error_message_code OUT NOCOPY VARCHAR2)
IS
	l_dummy NUMBER DEFAULT 0;

BEGIN

	IF (p_sys_link_func NOT IN ('OT', 'ST')) THEN

	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_SYSLINK_NOT_OTST';
	  return;

	ELSE

	  select count(*)
      into l_dummy
      from pa_expenditure_types_expend_v
      where p_ei_date between expnd_typ_start_date_active
      and nvl(expnd_typ_end_date_active,p_ei_date)
      and p_ei_date between SYS_LINK_START_DATE_ACTIVE
      and nvl(sys_link_end_date_active,p_ei_date)
      and system_linkage_function = p_sys_link_func
      and expenditure_type = p_exp_type;

	END IF;

    IF (l_dummy = 0) THEN
	   x_valid := 'N';
    ELSE
       x_valid := 'Y';
    END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  x_valid := 'N';
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_EXPTYPE_SYSLINK_INVALID';
    WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_error_message_code := Null;
      x_valid := 'N';

END Check_Exp_Type_Sys_Link_Combo;
/* New function GET_LATEST_DATE_PERIOD_NAME added for Bug 6450225 Start */
FUNCTION GET_LATEST_DATE_PERIOD_NAME ( P_EXP_ITEM_ID IN NUMBER,
				       P_FUN_CTL     IN VARCHAR	) RETURN VARCHAR2

IS

  BEGIN

        IF P_EXP_ITEM_ID = NVL(G_EXP_ITEM_ID,-999) THEN

	  IF  P_FUN_CTL = 'GL_DATE'  THEN
	                  RETURN TO_CHAR(G_GL_DATE);
	  ELSIF  P_FUN_CTL = 'PA_DATE'  THEN
	                  RETURN TO_CHAR(G_PA_DATE);
	  ELSIF  P_FUN_CTL = 'RECVR_PA_DATE'  THEN
	                  RETURN TO_CHAR(G_RECVR_PA_DATE);
	  ELSIF  P_FUN_CTL = 'RECVR_GL_DATE'  THEN
	                  RETURN TO_CHAR(G_RECVR_GL_DATE);
	  ELSIF  P_FUN_CTL = 'PA_PERIOD_NAME'  THEN
	                  RETURN G_PA_PERIOD_NAME;
	  ELSIF  P_FUN_CTL = 'GL_PERIOD_NAME'  THEN
	                  RETURN G_GL_PERIOD_NAME;
	  ELSIF  P_FUN_CTL = 'RECVR_PA_PERIOD_NAME'  THEN
	                  RETURN G_RECVR_PA_PERIOD_NAME;
	  ELSIF  P_FUN_CTL = 'RECVR_GL_PERIOD_NAME'  THEN
	                  RETURN G_RECVR_GL_PERIOD_NAME;
	  END IF;

        ELSE

                SELECT 	PA_DATE,
			GL_DATE,
			RECVR_PA_DATE,
			RECVR_GL_DATE,
			PA_PERIOD_NAME,
			GL_PERIOD_NAME,
			RECVR_PA_PERIOD_NAME,
			RECVR_GL_PERIOD_NAME
                INTO
			G_PA_DATE,
			G_GL_DATE,
			G_RECVR_PA_DATE,
			G_RECVR_GL_DATE,
			G_PA_PERIOD_NAME,
			G_GL_PERIOD_NAME,
			G_RECVR_PA_PERIOD_NAME,
			G_RECVR_GL_PERIOD_NAME
                FROM PA_COST_DISTRIBUTION_LINES_ALL
                WHERE EXPENDITURE_ITEM_ID = P_EXP_ITEM_ID
                AND LINE_TYPE = 'R'
		AND LINE_NUM_REVERSED IS NULL
		AND REVERSED_FLAG IS NULL ;

                G_EXP_ITEM_ID := P_EXP_ITEM_ID;

        END IF;

	  IF  P_FUN_CTL = 'GL_DATE'  THEN
	                  RETURN TO_CHAR(G_GL_DATE);
	  ELSIF  P_FUN_CTL = 'PA_DATE'  THEN
	                  RETURN TO_CHAR(G_PA_DATE);
	  ELSIF  P_FUN_CTL = 'RECVR_PA_DATE'  THEN
	                  RETURN TO_CHAR(G_RECVR_PA_DATE);
	  ELSIF  P_FUN_CTL = 'RECVR_GL_DATE'  THEN
	                  RETURN TO_CHAR(G_RECVR_GL_DATE);
	  ELSIF  P_FUN_CTL = 'PA_PERIOD_NAME'  THEN
	                  RETURN G_PA_PERIOD_NAME;
	  ELSIF  P_FUN_CTL = 'GL_PERIOD_NAME'  THEN
	                  RETURN G_GL_PERIOD_NAME;
	  ELSIF  P_FUN_CTL = 'RECVR_PA_PERIOD_NAME'  THEN
	                  RETURN G_RECVR_PA_PERIOD_NAME;
	  ELSIF  P_FUN_CTL = 'RECVR_GL_PERIOD_NAME'  THEN
	                  RETURN G_RECVR_GL_PERIOD_NAME;
	  END IF;

  EXCEPTION
        WHEN OTHERS THEN
                G_EXP_ITEM_ID := P_EXP_ITEM_ID;
                G_PA_DATE := NULL;
                G_GL_DATE := NULL;
                G_RECVR_PA_DATE := NULL;
                G_RECVR_GL_DATE := NULL;
                G_PA_PERIOD_NAME := NULL;
                G_GL_PERIOD_NAME := NULL;
                G_RECVR_PA_PERIOD_NAME := NULL;
                G_RECVR_GL_PERIOD_NAME := NULL;
                RETURN (NULL);

END GET_LATEST_DATE_PERIOD_NAME;
/* New function GET_LATEST_DATE_PERIOD_NAME added for Bug 6450225 End */

Function Get_Latest_GL_Date(P_Exp_Item_Id IN NUMBER) return DATE is

  Begin

        If P_Exp_Item_Id = nvl(G_Exp_Item_Id,-999) Then

                Return G_GL_Date;

        Else

                Select 	pa_date,
			gl_date,
			recvr_pa_date,
			recvr_gl_date,
			pa_period_name,
			gl_period_name,
			recvr_pa_period_name,
			recvr_gl_period_name
                Into
			g_pa_date,
			g_gl_date,
			g_recvr_pa_date,
			g_recvr_gl_date,
			g_pa_period_name,
			g_gl_period_name,
			g_recvr_pa_period_name,
			g_recvr_Gl_period_name
                From pa_cost_distribution_lines_all
                Where expenditure_item_id = P_Exp_Item_Id
                And line_type = 'R'
                And line_num = (
                        Select max(line_num)
                        From pa_cost_distribution_lines_all
                        Where expenditure_item_id = P_Exp_Item_Id
                        And line_type = 'R');

                G_exp_item_id := P_Exp_item_Id;

        End If;

        Return G_GL_Date;

  Exception
        When OTHERS Then
                G_exp_item_id := P_Exp_item_Id;
                G_Pa_Date := Null;
                G_Gl_Date := Null;
                G_Recvr_Pa_Date := Null;
                G_Recvr_Gl_Date := Null;
                G_Pa_Period_Name := Null;
                G_Gl_Period_Name := Null;
                G_Recvr_Pa_Period_Name := Null;
                G_Recvr_Gl_Period_Name := Null;
                Return (NULL);

End Get_Latest_GL_Date;

Function Get_Latest_PA_Date(P_Exp_Item_Id IN NUMBER) return DATE is

  Begin

	If P_Exp_Item_Id = nvl(G_Exp_Item_Id,-999) Then

		Return G_Pa_Date;

	Else

                Select  pa_date,
                        gl_date,
                        recvr_pa_date,
                        recvr_gl_date,
                        pa_period_name,
                        gl_period_name,
                        recvr_pa_period_name,
                        recvr_gl_period_name
                Into
                        g_pa_date,
                        g_gl_date,
                        g_recvr_pa_date,
                        g_recvr_gl_date,
                        g_pa_period_name,
                        g_gl_period_name,
                        g_recvr_pa_period_name,
                        g_recvr_Gl_period_name
		From pa_cost_distribution_lines_all
		Where expenditure_item_id = P_Exp_Item_Id
		And line_type = 'R'
		And line_num = (
			Select max(line_num)
			From pa_cost_distribution_lines_all
			Where expenditure_item_id = P_Exp_Item_Id
			And line_type = 'R');

		G_exp_item_id := P_Exp_item_Id;

	End If;

	Return G_PA_Date;

  Exception
	When OTHERS Then
		G_exp_item_id := P_Exp_item_Id;
		G_Pa_Date := Null;
		G_Gl_Date := Null;
                G_Recvr_Pa_Date := Null;
                G_Recvr_Gl_Date := Null;
                G_Pa_Period_Name := Null;
                G_Gl_Period_Name := Null;
                G_Recvr_Pa_Period_Name := Null;
                G_Recvr_Gl_Period_Name := Null;
		Return (NULL);

End Get_Latest_PA_Date;

Function Get_Latest_Recvr_Pa_Date(P_Exp_Item_Id IN NUMBER) return DATE is

  Begin

        If P_Exp_Item_Id = nvl(G_Exp_Item_Id,-999) Then

                Return G_Recvr_Pa_Date;

        Else

                Select  pa_date,
                        gl_date,
                        recvr_pa_date,
                        recvr_gl_date,
                        pa_period_name,
                        gl_period_name,
                        recvr_pa_period_name,
                        recvr_gl_period_name
                Into
                        g_pa_date,
                        g_gl_date,
                        g_recvr_pa_date,
                        g_recvr_gl_date,
                        g_pa_period_name,
                        g_gl_period_name,
                        g_recvr_pa_period_name,
                        g_recvr_Gl_period_name
                From pa_cost_distribution_lines_all
                Where expenditure_item_id = P_Exp_Item_Id
                And line_type = 'R'
                And line_num = (
                        Select max(line_num)
                        From pa_cost_distribution_lines_all
                        Where expenditure_item_id = P_Exp_Item_Id
                        And line_type = 'R');

                G_exp_item_id := P_Exp_item_Id;

        End If;

        Return G_Recvr_Pa_Date;

  Exception
        When OTHERS Then
                G_exp_item_id := P_Exp_item_Id;
                G_Pa_Date := Null;
                G_Gl_Date := Null;
                G_Recvr_Pa_Date := Null;
                G_Recvr_Gl_Date := Null;
                G_Pa_Period_Name := Null;
                G_Gl_Period_Name := Null;
                G_Recvr_Pa_Period_Name := Null;
                G_Recvr_Gl_Period_Name := Null;
                Return (NULL);

End Get_Latest_Recvr_Pa_Date;


Function Get_Latest_Recvr_Gl_Date(P_Exp_Item_Id IN NUMBER) return DATE is

  Begin

        If P_Exp_Item_Id = nvl(G_Exp_Item_Id,-999) Then

                Return G_Recvr_Gl_Date;

        Else

                Select  pa_date,
                        gl_date,
                        recvr_pa_date,
                        recvr_gl_date,
                        pa_period_name,
                        gl_period_name,
                        recvr_pa_period_name,
                        recvr_gl_period_name
                Into
                        g_pa_date,
                        g_gl_date,
                        g_recvr_pa_date,
                        g_recvr_gl_date,
                        g_pa_period_name,
                        g_gl_period_name,
                        g_recvr_pa_period_name,
                        g_recvr_Gl_period_name
                From pa_cost_distribution_lines_all
                Where expenditure_item_id = P_Exp_Item_Id
                And line_type = 'R'
                And line_num = (
                        Select max(line_num)
                        From pa_cost_distribution_lines_all
                        Where expenditure_item_id = P_Exp_Item_Id
                        And line_type = 'R');

                G_exp_item_id := P_Exp_item_Id;

	End If;

        Return G_Recvr_Gl_Date;

  Exception
        When OTHERS Then
                G_exp_item_id := P_Exp_item_Id;
                G_Pa_Date := Null;
                G_Gl_Date := Null;
                G_Recvr_Pa_Date := Null;
                G_Recvr_Gl_Date := Null;
                G_Pa_Period_Name := Null;
                G_Gl_Period_Name := Null;
                G_Recvr_Pa_Period_Name := Null;
                G_Recvr_Gl_Period_Name := Null;
                Return (NULL);

End Get_Latest_Recvr_Gl_Date;


Function Get_Latest_Pa_Per_Name(P_Exp_Item_Id IN NUMBER) return VARCHAR2 is

  Begin

        If P_Exp_Item_Id = nvl(G_Exp_Item_Id,-999) Then

                Return G_Pa_Period_Name;

        Else

                Select  pa_date,
                        gl_date,
                        recvr_pa_date,
                        recvr_gl_date,
                        pa_period_name,
                        gl_period_name,
                        recvr_pa_period_name,
                        recvr_gl_period_name
                Into
                        g_pa_date,
                        g_gl_date,
                        g_recvr_pa_date,
                        g_recvr_gl_date,
                        g_pa_period_name,
                        g_gl_period_name,
                        g_recvr_pa_period_name,
                        g_recvr_Gl_period_name
                From pa_cost_distribution_lines_all
                Where expenditure_item_id = P_Exp_Item_Id
                And line_type = 'R'
                And line_num = (
                        Select max(line_num)
                        From pa_cost_distribution_lines_all
                        Where expenditure_item_id = P_Exp_Item_Id
                        And line_type = 'R');

                G_exp_item_id := P_Exp_item_Id;

	End If;

        Return G_Pa_Period_Name;

  Exception
        When OTHERS Then
                G_exp_item_id := P_Exp_item_Id;
                G_Pa_Date := Null;
                G_Gl_Date := Null;
                G_Recvr_Pa_Date := Null;
                G_Recvr_Gl_Date := Null;
                G_Pa_Period_Name := Null;
                G_Gl_Period_Name := Null;
                G_Recvr_Pa_Period_Name := Null;
                G_Recvr_Gl_Period_Name := Null;
                Return (NULL);

End Get_Latest_Pa_Per_Name;


Function Get_Latest_Gl_Per_Name(P_Exp_Item_Id IN NUMBER) return VARCHAR2 is

  Begin

        If P_Exp_Item_Id = nvl(G_Exp_Item_Id,-999) Then

                Return G_Gl_Period_Name;

        Else

                Select  pa_date,
                        gl_date,
                        recvr_pa_date,
                        recvr_gl_date,
                        pa_period_name,
                        gl_period_name,
                        recvr_pa_period_name,
                        recvr_gl_period_name
                Into
                        g_pa_date,
                        g_gl_date,
                        g_recvr_pa_date,
                        g_recvr_gl_date,
                        g_pa_period_name,
                        g_gl_period_name,
                        g_recvr_pa_period_name,
                        g_recvr_Gl_period_name
                From pa_cost_distribution_lines_all
                Where expenditure_item_id = P_Exp_Item_Id
                And line_type = 'R'
                And line_num = (
                        Select max(line_num)
                        From pa_cost_distribution_lines_all
                        Where expenditure_item_id = P_Exp_Item_Id
                        And line_type = 'R');

                G_exp_item_id := P_Exp_item_Id;

	End If;

        Return G_Gl_Period_Name;

  Exception
        When OTHERS Then
                G_exp_item_id := P_Exp_item_Id;
                G_Pa_Date := Null;
                G_Gl_Date := Null;
                G_Recvr_Pa_Date := Null;
                G_Recvr_Gl_Date := Null;
                G_Pa_Period_Name := Null;
                G_Gl_Period_Name := Null;
                G_Recvr_Pa_Period_Name := Null;
                G_Recvr_Gl_Period_Name := Null;
                Return (NULL);

End Get_Latest_Gl_Per_Name;


Function Get_Latest_Recvr_Pa_Per_Name(P_Exp_Item_Id IN NUMBER) return VARCHAR2 is

  Begin

        If P_Exp_Item_Id = nvl(G_Exp_Item_Id,-999) Then

                Return G_Recvr_Pa_Period_Name;

        Else

                Select  pa_date,
                        gl_date,
                        recvr_pa_date,
                        recvr_gl_date,
                        pa_period_name,
                        gl_period_name,
                        recvr_pa_period_name,
                        recvr_gl_period_name
                Into
                        g_pa_date,
                        g_gl_date,
                        g_recvr_pa_date,
                        g_recvr_gl_date,
                        g_pa_period_name,
                        g_gl_period_name,
                        g_recvr_pa_period_name,
                        g_recvr_Gl_period_name
                From pa_cost_distribution_lines_all
                Where expenditure_item_id = P_Exp_Item_Id
                And line_type = 'R'
                And line_num = (
                        Select max(line_num)
                        From pa_cost_distribution_lines_all
                        Where expenditure_item_id = P_Exp_Item_Id
                        And line_type = 'R');

                G_exp_item_id := P_Exp_item_Id;

	End If;

        Return G_Recvr_Pa_Period_Name;

  Exception
        When OTHERS Then
                G_exp_item_id := P_Exp_item_Id;
                G_Pa_Date := Null;
                G_Gl_Date := Null;
                G_Recvr_Pa_Date := Null;
                G_Recvr_Gl_Date := Null;
                G_Pa_Period_Name := Null;
                G_Gl_Period_Name := Null;
                G_Recvr_Pa_Period_Name := Null;
                G_Recvr_Gl_Period_Name := Null;
                Return (NULL);

End Get_Latest_Recvr_Pa_Per_Name;


Function Get_Latest_Recvr_Gl_Per_Name(P_Exp_Item_Id IN NUMBER) return VARCHAR2 is

  Begin

        If P_Exp_Item_Id = nvl(G_Exp_Item_Id,-999) Then

                Return G_Recvr_Gl_Period_Name;

        Else

                Select  pa_date,
                        gl_date,
                        recvr_pa_date,
                        recvr_gl_date,
                        pa_period_name,
                        gl_period_name,
                        recvr_pa_period_name,
                        recvr_gl_period_name
                Into
                        g_pa_date,
                        g_gl_date,
                        g_recvr_pa_date,
                        g_recvr_gl_date,
                        g_pa_period_name,
                        g_gl_period_name,
                        g_recvr_pa_period_name,
                        g_recvr_gl_period_name
                From pa_cost_distribution_lines_all
                Where expenditure_item_id = P_Exp_Item_Id
                And line_type = 'R'
                And line_num = (
                        Select max(line_num)
                        From pa_cost_distribution_lines_all
                        Where expenditure_item_id = P_Exp_Item_Id
                        And line_type = 'R');

                G_exp_item_id := P_Exp_item_Id;

        End If;

        Return G_Recvr_Gl_Period_Name;

  Exception
        When OTHERS Then
                G_exp_item_id := P_Exp_item_Id;
                G_Pa_Date := Null;
                G_Gl_Date := Null;
                G_Recvr_Pa_Date := Null;
                G_Recvr_Gl_Date := Null;
                G_Pa_Period_Name := Null;
                G_Gl_Period_Name := Null;
                G_Recvr_Pa_Period_Name := Null;
                G_Recvr_Gl_Period_Name := Null;
                Return (NULL);

End Get_Latest_Recvr_Gl_Per_Name;


/* New function GET_ORG_NAME_WOSEC added for Bug 9321568 Start */
FUNCTION GET_ORG_NAME_WOSEC ( P_Org_ID IN NUMBER ) RETURN VARCHAR2
IS
   X_ORG_NAME     HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE ;

BEGIN
  IF P_ORG_ID IS NULL THEN
       RETURN(NULL);
  END IF;

        SELECT
            TL.NAME
          INTO
            X_ORG_NAME
         FROM
          HR_ALL_ORGANIZATION_UNITS_TL TL
         WHERE
           TL.ORGANIZATION_ID = P_ORG_ID
           AND TL.LANGUAGE = USERENV('LANG') ;

  RETURN (X_ORG_NAME);

EXCEPTION

    WHEN  OTHERS  THEN
      Return (NULL);
  END GET_ORG_NAME_WOSEC;




END PA_EXPENDITURES_UTILS;

/
