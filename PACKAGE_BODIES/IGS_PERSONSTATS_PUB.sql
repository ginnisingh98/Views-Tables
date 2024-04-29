--------------------------------------------------------
--  DDL for Package Body IGS_PERSONSTATS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PERSONSTATS_PUB" AS
/* $Header: IGSPAPSB.pls 120.0 2006/05/02 05:37:47 apadegal noship $ */
G_PKG_NAME 	CONSTANT VARCHAR2 (30):='IGS_PERSONSTATS_PUB';

PROCEDURE check_length(p_param_name IN VARCHAR2, p_table_name IN VARCHAR2, p_param_length IN NUMBER) AS
 CURSOR c_col_length IS
  SELECT WIDTH , precision , column_type ,scale
  FROM FND_COLUMNS
  WHERE  table_id IN
    (SELECT TABLE_ID
     FROM FND_TABLES
     WHERE table_name = p_table_name AND APPLICATION_ID = 8405)
  AND column_name = p_param_name
  AND APPLICATION_ID = 8405;

  l_col_length  c_col_length%ROWTYPE;
begin
  OPEN 	c_col_length;
  FETCH   c_col_length INTO  l_col_length;
  CLOSE  c_col_length;
  IF l_col_length.column_type = 'V' AND p_param_length > l_col_length.width  THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_EXCEED_MAX_LENGTH');
       FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
       FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.width);
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;


  ELSIF 	l_col_length.column_type ='N' AND p_param_length > (l_col_length.precision - l_col_length.scale) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_EXCEED_MAX_LENGTH');
       FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
       IF l_col_length.scale > 0 THEN
          FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.precision || ',' || l_col_length.scale);
       ELSE
          FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.precision );
       END IF;
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;


END check_length;





 --API
 PROCEDURE REDERIVE_PERSON_STATS(
 --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
                    p_person_id            IN      NUMBER,
                    p_group_id             IN      NUMBER,
		    x_return_status_tbl	   OUT     NOCOPY  Return_Status_Tbl_Type
)
 AS
  l_api_version         CONSTANT    	NUMBER := '1.0';
  l_api_name  	    	CONSTANT    	VARCHAR2(30) := 'REDERIVE_PERSONSTATS';
  l_msg_index                           NUMBER;
  l_return_status                       VARCHAR2(1);
  l_hash_msg_name_text_type_tab         igs_ad_gen_016.g_msg_name_text_type_table;
  l_ctr                NUMBER DEFAULT 0;
  l_person_id         NUMBER;
  l_group_id          NUMBER;
  l_ind_g_exec_error  BOOLEAN DEFAULT FALSE;	       -- individual unexpected err occured
  l_ind_unc_exec_error  BOOLEAN DEFAULT FALSE;	       -- individual generic err occured



  CURSOR  c_person_group IS
  SELECT
    person_id
  FROM
    igs_pe_prsid_grp_mem_v
  WHERE   group_id = p_group_id
  AND          NVL(TRUNC(start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
  AND          NVL(TRUNC(end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);

  CURSOR c_group_id(p_person_id  hz_parties.party_id%TYPE,p_group_id igs_pe_persid_group.group_id%TYPE)  IS
        SELECT 'X'
	FROM igs_pe_prsid_grp_mem
	WHERE  person_id = p_person_id
	AND group_id = p_group_id
  AND NVL(TRUNC(start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
  AND NVL(TRUNC(end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);
  l_exists VARCHAR2(1);

 BEGIN

  l_msg_index   := 0;

     -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;


-- Validate all the parameters for their length
-- PERSON_ID
     check_length('PERSON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_person_id)));
-- P_GROUP_ID
     check_length('GROUP_ID', 'IGS_PE_PERSID_GROUP_ALL', length(TRUNC(p_group_id)));
 --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
 ------------------------------
  --Intialization of varable to handle G_MISS_CHAR/NUM/DATE
  -------------------------------

    IF 	p_group_id IS NOT NULL and  p_person_id IS NOT NULL
    THEN
	    OPEN c_group_id(p_person_id,p_group_id);
	    FETCH c_group_id INTO l_exists;
	    IF c_group_id%NOTFOUND THEN
		   FND_MESSAGE.SET_NAME('IGS','IGS_AD_INVALID_PER_ID_GRP');
	           IGS_GE_MSG_STACK.ADD;
		   RAISE FND_API.G_EXC_ERROR;

	    END IF;
	    CLOSE c_group_id;
    END IF;

    IF 	p_group_id IS NULL and  p_person_id IS NULL
    THEN
	   FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRS_PRSIDGRP_NULL');
           IGS_GE_MSG_STACK.ADD;
	   RAISE FND_API.G_EXC_ERROR;

    END IF;


	  IF p_group_id IS  NULL THEN

	       IF p_person_id IS NOT NULL THEN     --When p_group_id is not null and p_person_id is null

			l_msg_index := igs_ge_msg_stack.count_msg;
			BEGIN
				SAVEPOINT REDERIVE_PERSON_STATS_PUB;

				IGS_AD_UPD_INITIALISE.update_per_stats(p_person_id,NULL);

				IF FND_API.To_Boolean( p_commit ) THEN
					COMMIT WORK;
				END IF;
				x_return_status := FND_API.G_RET_STS_SUCCESS;
				-- Standard call to get message count and if count is 1, get message info.
		        EXCEPTION
				WHEN FND_API.G_EXC_ERROR  THEN
				    ROLLBACK TO REDERIVE_PERSON_STATS_PUB;
				    x_return_status := FND_API.G_RET_STS_ERROR ;
	 		            igs_ad_gen_016.extract_msg_from_stack (
									   p_msg_at_index		=> l_msg_index,
									   p_return_status		 => l_return_status,
									   p_msg_count                   => x_msg_count,
									   p_msg_data                    => x_msg_data,
									   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
				    x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
				    x_msg_count := x_msg_count-1;

			      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
				    ROLLBACK TO REDERIVE_PERSON_STATS_PUB;
				    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
								p_data  => x_msg_data);

			      WHEN OTHERS THEN
				    ROLLBACK TO REDERIVE_PERSON_STATS_PUB;
			            igs_ad_gen_016.extract_msg_from_stack (
									   p_msg_at_index                => l_msg_index,
									   p_return_status               => l_return_status,
									   p_msg_count                   => x_msg_count,
									   p_msg_data                    => x_msg_data,
									   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
				    IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
				        x_return_status := FND_API.G_RET_STS_ERROR ;
				    ELSE
				        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				    END IF;
       		         END;
	       END IF;
	 ELSE			    -- group id is passed


		 FOR c_person_group_rec in c_person_group
		 LOOP
				     l_ctr := l_ctr + 1;
				     l_msg_index := igs_ge_msg_stack.count_msg;
				     BEGIN
						SAVEPOINT REDERIVE_PERSON_STATS_PUB;
						x_return_status_tbl(l_ctr).Person_id := c_person_group_rec.person_id;
						IGS_AD_UPD_INITIALISE.update_per_stats(c_person_group_rec.person_id,NULL);

						IF FND_API.To_Boolean( p_commit ) THEN
							COMMIT WORK;
						END IF;

						x_return_status_tbl(l_ctr).sub_return_status := FND_API.G_RET_STS_SUCCESS;
						x_return_status := FND_API.G_RET_STS_SUCCESS;
						-- Standard call to get message count and if count is 1, get message info.
				      EXCEPTION
						WHEN FND_API.G_EXC_ERROR  THEN
							l_ind_g_exec_error  := TRUE;
							ROLLBACK TO REDERIVE_PERSON_STATS_PUB;
							x_return_status_tbl(l_ctr).sub_return_status := FND_API.G_RET_STS_ERROR ;
							igs_ad_gen_016.extract_msg_from_stack (
										   p_msg_at_index                => l_msg_index,
										   p_return_status               => l_return_status,
										   p_msg_count                   => x_return_status_tbl(l_ctr).sub_msg_count,
										   p_msg_data                    => x_return_status_tbl(l_ctr).sub_msg_data,
										   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
							x_return_status_tbl(l_ctr).sub_msg_data := l_hash_msg_name_text_type_tab(x_return_status_tbl(l_ctr).sub_msg_count-2).text;
							x_return_status_tbl(l_ctr).sub_msg_count := x_return_status_tbl(l_ctr).sub_msg_count-1;

					       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
							l_ind_unc_exec_error := TRUE;
							ROLLBACK TO REDERIVE_PERSON_STATS_PUB;
							x_return_status_tbl(l_ctr).sub_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
							FND_MSG_PUB.Count_And_Get(p_count => x_return_status_tbl(l_ctr).sub_msg_count,
										p_data  => x_return_status_tbl(l_ctr).sub_msg_data);

					       WHEN OTHERS THEN

							ROLLBACK TO REDERIVE_PERSON_STATS_PUB;

							igs_ad_gen_016.extract_msg_from_stack (
										   p_msg_at_index                => l_msg_index,
										   p_return_status               => l_return_status,
										   p_msg_count                   => x_return_status_tbl(l_ctr).sub_msg_count,
										   p_msg_data                    => x_return_status_tbl(l_ctr).sub_msg_data,
										   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);


							IF l_hash_msg_name_text_type_tab(x_return_status_tbl(l_ctr).sub_msg_count-1).name <>  'ORA'  THEN
							    l_ind_g_exec_error  := TRUE;
							    x_return_status_tbl(l_ctr).sub_return_status := FND_API.G_RET_STS_ERROR ;
							ELSE
							    l_ind_unc_exec_error := TRUE;
							    x_return_status_tbl(l_ctr).sub_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
							END IF;

				      END;
		 END LOOP;

		 IF  l_ind_unc_exec_error THEN
		      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 ELSIF 	l_ind_g_exec_error THEN
		      x_return_status := FND_API.G_RET_STS_ERROR ;
		 ELSE
		      x_return_status := FND_API.G_RET_STS_SUCCESS;
		 END IF;
	 END IF;
 EXCEPTION   ---- This expection block is for the whole api.
			WHEN FND_API.G_EXC_ERROR  THEN

			    x_return_status := FND_API.G_RET_STS_ERROR ;
		       igs_ad_gen_016.extract_msg_from_stack (
				   p_msg_at_index                => l_msg_index,
				   p_return_status               => l_return_status,
				   p_msg_count                   => x_msg_count,
				   p_msg_data                    => x_msg_data,
				   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
			    x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
			    x_msg_count := x_msg_count-1;

		      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
						p_data  => x_msg_data);

		      WHEN OTHERS THEN


		       igs_ad_gen_016.extract_msg_from_stack (
				   p_msg_at_index                => l_msg_index,
				   p_return_status               => l_return_status,
				   p_msg_count                   => x_msg_count,
				   p_msg_data                    => x_msg_data,
				   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

			  IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
			    x_return_status := FND_API.G_RET_STS_ERROR ;
			  ELSE
			    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			  END IF;


 END REDERIVE_PERSON_STATS;




 END IGS_PERSONSTATS_PUB;

/
