--------------------------------------------------------
--  DDL for Package Body GMO_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DRT_PKG" AS
/* $Header: GMODRCB.pls 120.0.12010000.5 2018/06/05 06:13:40 maychen noship $ */



 PROCEDURE GMO_FND_DRC
  (PERSON_ID       IN         NUMBER,
   RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE)
 AS

  l_proc_name           VARCHAR2(72):='GMO_DRT_PKG.GMO_FND_DRC';
  l_user_id             NUMBER;
  n                     NUMBER := 0;
  l_user_name           FND_USER.USER_NAME%TYPE;
  l_user_display_name   VARCHAR2(240);
  l_count               NUMBER;
  l_message_text VARCHAR2(2000);
  L_DEBUG        BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <=
                              FND_LOG.LEVEL_EVENT;

BEGIN

 	l_user_id := person_id;

  IF L_DEBUG THEN
		fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name,
	 	'Start GMO_FND_DRC.GMO_FND_DRC for current FND USER_ID:' || l_user_id );
	END IF;


  l_user_id := person_id;

  --get fnd user_name
  BEGIN
  SELECT USER_NAME
  	INTO l_user_name
  FROM FND_USER
  WHERE USER_ID = l_user_id;

  EXCEPTION
	  when no_data_found then


			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'INVALID PERSON_ID' );


			END IF;

			return;
 	end;


  --step1, checking on table GMO_OPERATOR_CERT_TRANS

	l_count := 0;


	select count(1)
		into l_count
	from GMO_OPERATOR_CERT_TRANS
	where USER_ID = l_user_id
	and rownum=1;


	IF l_count > 0 THEN

		per_drt_pkg.add_to_results(
			person_id     => l_user_id,
			entity_type   => 'FND',
			status        => 'W',
			msgcode       => 'GMO_GDPR_DRC_ERROR',
			msgaplid      => 560,
			RESULT_TBL    => RESULT_TBL
		);
		N := RESULT_TBL.COUNT ;


		IF L_DEBUG THEN
			fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' ||  FND_MESSAGE.GET_STRING('GMO',RESULT_TBL(N).msgcode) );
		END IF;

	ELSE
		select count(1)
			into l_count
		from GMO_OPERATOR_CERT_TRANS
		where  OVERRIDER_ID = l_user_id
		and rownum=1;


		IF l_count > 0 THEN

			per_drt_pkg.add_to_results(
				person_id     => l_user_id,
				entity_type   => 'FND',
				status        => 'W',
				msgcode       => 'GMO_GDPR_DRC_ERROR',
				msgaplid      => 560,
				RESULT_TBL    => RESULT_TBL
			);
			N := RESULT_TBL.COUNT ;


			IF L_DEBUG THEN
				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
					|| ', Message Text: ' ||  FND_MESSAGE.GET_STRING('GMO',RESULT_TBL(N).msgcode) );
			END IF;


		END IF;

	END IF;



 -- IF THERE IS NO error:
	IF N = 0 THEN

		per_drt_pkg.add_to_results(
			person_id     => l_user_id,
			entity_type   => 'FND',
			status        => 'S',
			msgcode       => NULL,
			msgaplid      => NULL,
			RESULT_TBL    => RESULT_TBL
		);
		N := RESULT_TBL.COUNT ;


		IF L_DEBUG THEN
			fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name, 'RESULT_TBL(' || N || ').STATUS: ' || RESULT_TBL(N).STATUS
				|| ', Message Text: ' ||  FND_MESSAGE.GET_STRING('GMO',RESULT_TBL(N).msgcode) );
		END IF;

	END IF ;

	 IF L_DEBUG THEN

				fnd_log.string(FND_LOG.LEVEL_EVENT, l_proc_name,
	 	'Completed GMO_FND_DRC for current FND USER_ID:' || l_user_id || ': USER_NAME: ' || l_user_name);

	END IF;





END GMO_FND_DRC;

END GMO_DRT_PKG;

/
