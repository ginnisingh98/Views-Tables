--------------------------------------------------------
--  DDL for Package Body FPA_PORTFOLIO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_PORTFOLIO_PVT" as
/* $Header: FPAVPTFB.pls 120.1 2005/08/18 11:46:58 appldev noship $ */

PROCEDURE Create_Portfolio
     (
    	p_api_version		IN		NUMBER,
	    p_portfolio_rec		IN		FPA_Portfolio_PVT.portfolio_rec_type,
	    x_portfolio_id	    OUT NOCOPY	VARCHAR2,
	    x_return_status		OUT NOCOPY	VARCHAR2,
	    x_msg_data			OUT NOCOPY	VARCHAR2,
	    x_msg_count			OUT NOCOPY	NUMBER

	)
IS
	-- A cursor to get the new unique id for the scenario
	CURSOR portfolio_s_c
	IS
	SELECT
		fpa_portfolio_s.nextval AS portfolio_id
	FROM
		dual;
    l_language                      varchar2(4);


    CURSOR c_language IS
    SELECT language_code
    FROM   fnd_languages
    WHERE  installed_flag IN ('I','B');

	-- A record to hold the new sequence value
	 portfolio_s_r 	portfolio_s_c%ROWTYPE;
BEGIN

	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.create_portfolio.begin',
			'Entering fpa_portfolo_pvt.create_portfolio'
		);
	END IF;

	-- Get the next sequence value for the scenario identifier
	OPEN portfolio_s_c;
	FETCH portfolio_s_c INTO portfolio_s_r;
	CLOSE portfolio_s_c;

	-- We return the id of the new scenario to the caller
	x_portfolio_id := portfolio_s_r.portfolio_id;

    -- Change it to handle for exception seciton *****

	-- Add the new  portfolio to the dimension
	dbms_aw.execute('MAINTAIN portfolio_d ADD '|| portfolio_s_r.portfolio_id );
	dbms_aw.execute('LMT portfolio_d TO '|| portfolio_s_r.portfolio_id );
    dbms_aw.execute('portfolio_class_code_m='|| p_portfolio_rec.portfolio_type );

	-- check if the organization is null , then update with NA
	IF p_portfolio_rec.portfolio_start_org_id IS NULL THEN
           dbms_aw.execute('portfolio_organization_m = NA');
        ELSE
    	dbms_aw.execute('portfolio_organization_m= '|| p_portfolio_rec.portfolio_start_org_id );
       END IF;


      --dbms_output.put_line('owner id is'||p_portfolio_rec.portfolio_owner_id);
	-- the below is deperecated , as the person id will nto be mainted in the AW
	 /*
        BEGIN
        dbms_aw.execute('MAINTAIN person_id_d ADD '|| p_portfolio_rec.portfolio_owner_id);
          EXCEPTION
   	    WHEN OTHERS THEN
            --dbms_output.put_line(SQLCODE);
  	    -- Check for existing dim values, if it already exists during MAINTAIN, then ignore it.
  	        IF SQLCODE = -34034 THEN
			    NULL;
            END IF;
        END;

        dbms_aw.execute('owner_portfolio_r= '|| p_portfolio_rec.portfolio_owner_id);
	  */

	   IF (c_language%ISOPEN) THEN
        CLOSE c_language;
       END IF;

     OPEN c_language;
      LOOP
        FETCH c_language INTO l_language;
        EXIT WHEN c_language%NOTFOUND;

       --dbms_output.put_line('before insert');


       -- Insert the record on the  pa_objects_tl table
        INSERT INTO FPA_OBJECTS_TL ( object,id, name,
                                    description, language, source_lang,
                                    created_by, creation_date, last_updated_by,
                                    last_update_date, last_update_login
                                    )
                                    VALUES
                                    ( 'PORTFOLIO',portfolio_s_r.portfolio_id,p_portfolio_rec.portfolio_name,
                                       p_portfolio_rec.portfolio_desc,
                                      l_Language,
                                      USERENV('LANG'),
                                      0,
                                      SYSDATE,
                                      0,
                                      SYSDATE,
                                      0
                                      );
         END LOOP;
        --dbms_output.put_line('after insert');


         CLOSE c_language;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa_portfolo_pvt.create_portfolio.end',
			'Exiting fpa_portfolio_pvt.create_portfolio'
		);
	END IF;


EXCEPTION
  	WHEN OTHERS THEN

  	 --dbms_output.put_line('eception portfolio creat');

		IF portfolio_s_c%ISOPEN THEN
			CLOSE portfolio_s_c;
		END IF;

       IF (c_language%ISOPEN) THEN
        CLOSE c_language;
       END IF;

		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_ERROR,
			'fpa_portfolio_pvt.create_portfolio',
			SQLERRM
		);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;
END create_portfolio;


/************************************************************************************
************************************************************************************/
-- The procedure Delete_Portfolio revmoves the portfolio from aw

PROCEDURE Delete_Portfolio
     (
       p_api_version		IN		    NUMBER,
       p_portfolio_id       IN          NUMBER,
       x_return_status		OUT NOCOPY	VARCHAR2,
	   x_msg_data			OUT NOCOPY	VARCHAR2,
	   x_msg_count			OUT NOCOPY	NUMBER
    )
 IS

BEGIN

  	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa_portfolio_pvt.Delete_Portfolio.begin',
			'Entering fpa_portfolio_pvt.Delete_Portfolio'
		);
	END IF;

  	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			' fpa_portfolio_pvt.Delete_Portfolio',
			' Before remove portfolio maintain portfolio_d '
		);
	END IF;

  	-- Delete the portfolio from the AW space.
	dbms_aw.Execute('maintain portfolio_d delete ' || p_portfolio_id );
  	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			' fpa_portfolio_pvt.Delete_Portfolio',
			' After remove portfolio maintain portfolio_d '
		);
	END IF;


     --Delete portfolio from FPA_OBJECTS_TL
 	 DELETE  FROM FPA_OBJECTS_TL
 	 WHERE object = 'PORTFOLIO'
  	 AND   id = p_portfolio_id;

    -- CHANGES PENDING
    -- 1) REMOVE CORRESPONDING PLANNING CYCLE
    -- 2) REMOVE CORRESPONDING PORTFOLIO USERSS



    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa_portfolio_pvt.Delete_Portfolio.end',
			'Exiting fpa_portfolio_pvt.Delete_Portfolio'
		);
	END IF;


EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_ERROR,
			'fpa_portfolio_pvt.Delete_Portfolio.end',
			SQLERRM
		);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END Delete_Portfolio;



/************************************************************************************
************************************************************************************/
-- The procedure Upadate_Portfolio_Descr update the portfolio description


PROCEDURE Upadate_Portfolio_Descr
        (
	    p_api_version		IN		NUMBER,
	    p_portfolio_rec		IN		FPA_Portfolio_PVT.portfolio_rec_type,
	    x_return_status		OUT NOCOPY	VARCHAR2,
        x_msg_data			OUT NOCOPY	VARCHAR2,
	    x_msg_count			OUT NOCOPY	NUMBER
		    )
IS
BEGIN

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.update_portfolio_Descr.begin',
			'Entering fpa_portfolo_pvt.update_portfolio_descr'
		);
        END IF;
                 UPDATE  FPA_OBJECTS_TL objtl
                SET objtl.NAME =p_portfolio_rec.portfolio_name,
                objtl.DESCRIPTION =p_portfolio_rec.portfolio_desc,
                objtl.SOURCE_LANG     = userenv('LANG')
                where objtl.id = p_portfolio_rec.portfolio_id
                and userenv('LANG') IN (objtl.LANGUAGE, objtl.SOURCE_LANG);


        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.update_portfolio_desc.end',
			'Exiting fpa_portfolo_pvt.update_portfolio_descr'
		);
        END IF;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_ERROR,
			'fpa_portfolio_pvt.update_portfolio',
			SQLERRM
		);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END; -- End Update_Portfolio


/************************************************************************************
************************************************************************************/
-- The procedure Upadate_Portfolio_type update the portfolio class code/type measure

PROCEDURE Upadate_Portfolio_type
        (
	    p_api_version		    IN		NUMBER,
  	    p_portfolio_id          IN      NUMBER,
  	    p_portfolio_class_code	IN		NUMBER,
	    x_return_status		    OUT NOCOPY	VARCHAR2,
        x_msg_data			    OUT NOCOPY	VARCHAR2,
	    x_msg_count			    OUT NOCOPY	NUMBER
		    )
IS
BEGIN
        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.update_portfolio_type.begin',
			'Entering fpa_portfolo_pvt.update_portfolio_type'
		);
        END IF;
    	-- Update name and description
	    dbms_aw.execute('LMT portfolio_d TO '||p_portfolio_id);
        dbms_aw.execute('portfolio_class_code_m='|| p_portfolio_class_code );

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.update_portfolio_type.end',
			'Exiting fpa_portfolo_pvt.update_portfolio_type'
		);
        END IF;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_ERROR,
			'fpa_portfolio_pvt.update_portfolio_type',
			SQLERRM
		);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END; -- End Update_Portfolio_type


/************************************************************************************
************************************************************************************/
-- The procedure Upadate_Portfolio_organization update the portfolio start organization measure

PROCEDURE Upadate_Portfolio_organization
        (
	    p_api_version		        IN		    NUMBER,
	    p_portfolio_id              IN          NUMBER,
  	    p_portfolio_organization	IN		    NUMBER,
	    x_return_status		        OUT NOCOPY	VARCHAR2,
        x_msg_data			        OUT NOCOPY	VARCHAR2,
	    x_msg_count			        OUT NOCOPY	NUMBER
		    )
IS
BEGIN

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.update_portfolio_organization.begin',
			'Entering fpa_portfolo_pvt.update_portfolio_organization'
		);
        END IF;
        dbms_aw.execute('LMT portfolio_d TO '||p_portfolio_id);
        IF p_portfolio_organization IS NULL THEN
            dbms_aw.execute('portfolio_organization_m = NA');
        ELSE
        dbms_aw.execute('portfolio_organization_m= '||  p_portfolio_organization );
        END IF;

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.update_portfolio_organization.end',
			'Exiting fpa_portfolo_pvt.update_portfolio_organization'
		);
        END IF;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_ERROR,
			'fpa_portfolio_pvt.update_portfolio_organization',
			SQLERRM
		);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END; -- End Update_Portfolio_organization


/************************************************************************************
************************************************************************************/
-- The procedure check_portfolio_name validates the duplicate portfolio name.

FUNCTION Check_Portfolio_name
     (
       p_api_version		IN		    NUMBER,
       p_portfolio_id       IN          NUMBER,
	   p_portfolio_name		IN		    VARCHAR2,
	   x_return_status		OUT NOCOPY	VARCHAR2,
       x_msg_data			OUT NOCOPY	VARCHAR2,
	   x_msg_count			OUT NOCOPY	NUMBER
	    )
return NUMBER
IS
PortfolioCnt NUMBER;
BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.Check_portfolio_name.begin',
			'Entering fpa_portfolo_pvt.Check_portfolio_name'
		);
  END IF;
   --dbms_output.PUT_LINE('portfolio name is '||p_portfolio_name);
   --dbms_output.PUT_LINE('portfolio id is '||p_portfolio_id);

-- Check if the portfolio name is exist
IF p_portfolio_id is NULL THEN
    -- Case will be for , Create portfolio
    SELECT count(*)
    INTO PortfolioCnt
    FROM fpa_portfs_vl portfo
    WHERE portfo.Name = p_portfolio_name;

ELSE
    -- case will be for, Update Portfolio
    SELECT count(*)
    INTO PortfolioCnt
    FROM fpa_portfs_vl portfo
    WHERE portfo.Name = p_portfolio_name
    AND Portfo.portfolio <> p_portfolio_id;
END IF;
    --dbms_output.PUT_LINE(PortfolioCnt);
    RETURN PortfolioCnt;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_portfolio_pvt.Check_portfolio_name.end',
			'Exting fpa_portfolo_pvt.Check_portfolio_name'
		);
  END IF;


EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_ERROR,
			'fpa_portfolio_pvt.Check_portfolio_name',
			SQLERRM
		);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
		);
		RAISE;

END; -- End Check_Portfolio_name


END;


/
