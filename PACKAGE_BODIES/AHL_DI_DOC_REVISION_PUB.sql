--------------------------------------------------------
--  DDL for Package Body AHL_DI_DOC_REVISION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_DOC_REVISION_PUB" AS
/* $Header: AHLPDORB.pls 120.1.12010000.2 2010/01/11 07:02:17 snarkhed ship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_DOC_REVISION_PUB';
/*-----------------------------------------------------------*/
/* procedure name: Check_lookup_name_Or_Id(private procedure)*/
/* description :  used to retrieve lookup code               */
/*                                                           */
/*-----------------------------------------------------------*/

--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE Check_lookup_name_Or_Id
 ( p_lookup_type      IN FND_LOOKUPS.lookup_type%TYPE,
   p_lookup_code      IN FND_LOOKUPS.lookup_code%TYPE,
   p_meaning          IN FND_LOOKUPS.meaning%TYPE,
   p_check_id_flag    IN VARCHAR2,
   x_lookup_code      OUT NOCOPY FND_LOOKUPS.lookup_code%TYPE,
   x_return_status    OUT NOCOPY VARCHAR2)
IS

BEGIN
      IF (p_lookup_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND lookup_code = p_lookup_code
            AND sysdate between start_date_active
            AND nvl(end_date_active,sysdate);
        ELSE
           x_lookup_code := p_lookup_code;
        END IF;
     ELSE
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND meaning     = p_meaning
            AND sysdate between start_date_active
            AND nvl(end_date_active,sysdate);
    END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN too_many_rows THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
END;
/*---------------------------------------------------*/
/* procedure name: create_revision                   */
/* description :  Creates new revision record        */
/*                for an associated document         */
/*                                                   */
/*---------------------------------------------------*/
PROCEDURE CREATE_REVISION
(
 p_api_version               IN     NUMBER    :=  1.0                ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl            IN OUT NOCOPY revision_tbl              ,
 p_module_type               IN     VARCHAR2                         ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2)
IS

--Check for ID based on the name
CURSOR get_party_name(c_approved_by_pty_name IN VARCHAR2)
 IS
 --Modified pjha:07-Aug-2002 for performance
 /*
 SELECT party_id
  FROM ahl_hz_per_employees_v
 WHERE upper(party_name) = upper(c_approved_by_pty_name);
 */
 -- changes for performance pbarman 7.5.2003
 SELECT party_id
 FROM hz_parties
 WHERE upper(PARTY_NAME) = upper(c_approved_by_pty_name)
 AND AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PER') IN ('N','L')
 AND party_type = 'PERSON'
 UNION
 SELECT person_id
 FROM per_people_f ppf,per_person_types ppt
 WHERE upper(FULL_NAME) = upper(c_approved_by_pty_name)
 AND trunc(sysdate) BETWEEN effective_start_date AND effective_end_date
 AND nvl(current_employee_flag, 'X') = 'Y'
 AND ppf.person_type_id = ppt.person_type_id
 AND system_person_type = 'EMP'
 AND AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PER') IN ('I','S');

-- Check for ID
CURSOR approved_by_party_id(c_approved_by_pty_id  IN NUMBER)
 IS
SELECT party_id
  FROM hz_parties
 WHERE party_id = c_approved_by_pty_id;

--Check for Name
CURSOR approved_by_party_desc(c_approved_by_pty_name  IN VARCHAR2)
 IS
SELECT party_id
  FROM hz_parties
 WHERE UPPER(party_name) = UPPER(c_approved_by_pty_name);

   --Used to retrieve the party id for party name and party id
    CURSOR get_party_name_id (c_party_name  IN VARCHAR2, c_party_id IN NUMBER)
    IS
    SELECT person_id
    FROM per_people_f ppf, per_person_types ppt
    WHERE upper(FULL_NAME) = upper(c_party_name)
      AND ppf.person_id = c_party_id
      AND trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
      AND nvl(ppf.current_employee_flag,'x') = 'Y'
      AND ppf.person_type_id = ppt.person_type_id
      AND ppt.system_person_type ='EMP';




--
 l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_REVISION';
 l_api_version   CONSTANT NUMBER       := 1.0;

 l_num_rec                NUMBER;
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);
 l_return_status          VARCHAR2(1);
 l_revision_type_code     VARCHAR2(30);
 l_media_type_code        VARCHAR2(30);
 l_revision_status_code   VARCHAR2(30);
 l_revision_status_type   VARCHAR2(30) := 'AHL_REVISION_STATUS_TYPE';
 l_revision_type          VARCHAR2(30) := 'AHL_REVISION_TYPE';
 l_approved_by_party_id   NUMBER;
 l_revision_tbl           AHL_DI_DOC_REVISION_PVT.revision_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;
 l_sysdate                DATE;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_revision;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_revision_pub.Create Revision','+REV+');

	END IF;
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
    x_return_status := 'S';
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Start of API Body
   IF p_x_revision_tbl.COUNT > 0
   THEN
     FOR i IN p_x_revision_tbl.FIRST..p_x_revision_tbl.LAST
     LOOP
         --For Approved by Party Id, Party Name is present
           IF (p_x_revision_tbl(i).approved_by_pty_name IS NOT NULL)
              THEN




             IF ahl_di_doc_index_pvt.get_product_install_status('PER') in ('N','L')
             THEN

                 OPEN  approved_by_party_desc(p_x_revision_tbl(i).approved_by_pty_name);
                 FETCH approved_by_party_desc INTO l_approved_by_party_id;
                 IF approved_by_party_desc%FOUND
                 THEN

                  p_x_revision_tbl(i).approved_by_party_id := l_approved_by_party_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_APP_BY_PTY_ID_NOT_EXIST');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE approved_by_party_desc;
             ELSIF ahl_di_doc_index_pvt.get_product_install_status('PER') in ('I','S')
             THEN
             -- modified for bugfix 2193744

		      OPEN get_party_name_id (p_x_revision_tbl(i).approved_by_pty_name, p_x_revision_tbl(i).approved_by_party_id);
	              FETCH get_party_name_id INTO l_approved_by_party_id;

	              -- If 1 record retrieved then party id and name match, use party id
	              p_x_revision_tbl(i).approved_by_party_id := l_approved_by_party_id;


	              -- If no records, then party name has been changed
	              IF get_party_name_id%NOTFOUND THEN


		           IF (p_x_revision_tbl(i).approved_by_party_id IS  NULL)
        	         THEN


		 		  		   OPEN get_party_name(p_x_revision_tbl(i).approved_by_pty_name);
		 		     		   LOOP
		 		    			    FETCH get_party_name INTO l_approved_by_party_id;
		 		    			    EXIT WHEN get_party_name%NOTFOUND;
		 		    		   END LOOP;

		 		    		  IF get_party_name%ROWCOUNT = 0 THEN
		 		    			  FND_MESSAGE.SET_NAME('AHL','AHL_DI_APP_BY_PTY_ID_NOT_EXIST');
		 		    			  FND_MSG_PUB.ADD;
		 		    		  ELSIF get_party_name%ROWCOUNT = 1 THEN
		 		    			  p_x_revision_tbl(i).approved_by_party_id := l_approved_by_party_id;
		 		    		  ELSE
		 		    		  -- It will show the message to use LOV , so it would take care
		 		    		  -- for duplicate records as well

		 		    			    FND_MESSAGE.SET_NAME('AHL','AHL_DI_APPROVED_BY_USE_LOV');
		 					    FND_MSG_PUB.ADD;

		 		    		  END IF;
		 		     		  CLOSE get_party_name;
				   END IF;
                     		   CLOSE get_party_name_id;

			END IF;
              -- modified for bugfix 2193744


               END IF;



            ELSE
                      /* If Party Name is not available then set the Party Id also to null */

                  p_x_revision_tbl(i).approved_by_party_id := null;

            END IF;
         --For Revision Type Code
       IF p_x_revision_tbl(i).revision_type_desc IS NOT NULL
       THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_REVISION_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_revision_tbl(i).revision_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).revision_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
         -- If Code is present
        IF p_x_revision_tbl(i).revision_type_code IS NOT NULL
         THEN
           l_revision_tbl(i).revision_type_code := p_x_revision_tbl(i).revision_type_code;
        --If both are missing
        ELSE
           l_revision_tbl(i).revision_type_code := p_x_revision_tbl(i).revision_type_code;
        END IF;
        --For Media Type Code, meaning is present
        IF p_x_revision_tbl(i).media_type_desc IS NOT NULL
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_MEDIA_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_revision_tbl(i).media_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).media_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_MEDTYP_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
         -- If ID presnt
        IF p_x_revision_tbl(i).media_type_code IS NOT NULL
         THEN
           l_revision_tbl(i).media_type_code := p_x_revision_tbl(i).media_type_code;
         --Both are missing
         ELSE
           l_revision_tbl(i).media_type_code := p_x_revision_tbl(i).media_type_code;
         END IF;
         --For Revision Status Code
         IF p_x_revision_tbl(i).revision_status_desc IS NOT NULL
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_REVISION_STATUS_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_revision_tbl(i).revision_status_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).revision_status_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_STAT_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- If Revision status code presents
         IF p_x_revision_tbl(i).revision_status_code IS NOT NULL
         THEN
           l_revision_tbl(i).revision_status_code := p_x_revision_tbl(i).revision_status_code;
         ELSE
          --Both are missing
           l_revision_tbl(i).revision_status_code := p_x_revision_tbl(i).revision_status_code;
         END IF;
        --

        --validations put for enhancements
        -- Enhancement no #2027019: pbarman : April 2003
	--if rev date is null then rev date = sysdate.

	IF p_x_revision_tbl(i).revision_date IS NULL
	THEN
	    SELECT TRUNC(SYSDATE) into p_x_revision_tbl(i).revision_date FROM DUAL;
	     -- truncate time stamp
	/* as per FP for ER 5859915 where PM had decided to remove following validation
	ELSE
	    SELECT SYSDATE into l_sysdate FROM DUAL;
	    IF p_x_revision_tbl(i).revision_date < TRUNC(l_sysdate)
	    THEN
	      FND_MESSAGE.SET_NAME('AHL','AHL_DI_REVDT_LESS_SYSDT');
              FND_MSG_PUB.ADD;
            END IF;
          */
	END IF;
/* Vineet - As per the FP for 11510 Bug 5930628 where PM had decided to remove all date validations except Revision date
        --if approved_date < revision_date then error

	IF p_x_revision_tbl(i).approved_date IS NOT NULL
	THEN
	   IF p_x_revision_tbl(i).approved_date < p_x_revision_tbl(i).revision_date
	   THEN
	       FND_MESSAGE.SET_NAME('AHL','AHL_DI_APVDT_LESS_REVDT');
               FND_MSG_PUB.ADD;
	   END IF;
	END IF;

-- As per the FP for bug 3662906 removing issue date validation
	--if( issue date  <  either of (approved date,revision date)) then error.
	--according to dld -- issue date has no validations but PM asked to put
        IF p_x_revision_tbl(i).issue_date IS NOT NULL
	THEN

	  IF p_x_revision_tbl(i).issue_date < nvl(p_x_revision_tbl(i).approved_date, p_x_revision_tbl(i).revision_date)
	  THEN
					IF p_x_revision_tbl(i).approved_date IS NULL
					THEN
							FND_MESSAGE.SET_NAME('AHL', 'AHL_DI_ISSDT_LESS_REVDT');
       FND_MSG_PUB.ADD;
					ELSE
	      FND_MESSAGE.SET_NAME('AHL','AHL_DI_ISSDT_LESS_APVDT');
       FND_MSG_PUB.ADD;
					END IF;
	  END IF;
	END IF;

	--if(effective date <  either of  (approved date, revision date))

        IF p_x_revision_tbl(i).effective_date IS NOT NULL
	THEN

	  IF p_x_revision_tbl(i).effective_date < nvl(p_x_revision_tbl(i).approved_date, p_x_revision_tbl(i).revision_date)
	  THEN
					IF p_x_revision_tbl(i).approved_date IS NULL
					THEN
							FND_MESSAGE.SET_NAME('AHL','AHL_DI_EFFDT_LESS_REVDT');
       FND_MSG_PUB.ADD;
					ELSE
 	     FND_MESSAGE.SET_NAME('AHL','AHL_DI_EFFDT_LESS_APVDT');
       FND_MSG_PUB.ADD;
					END IF;
	  END IF;
	END IF;

       --if(received_date > revision_date)

	IF p_x_revision_tbl(i).received_date IS NOT NULL
	THEN
	  IF p_x_revision_tbl(i).received_date > p_x_revision_tbl(i).revision_date
          THEN
	     FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECDT_GT_REVDT');
             FND_MSG_PUB.ADD;
	  END IF;
	END IF;
	*/
	-- if obsolete date is not null, check if it is less than any other date
	IF p_x_revision_tbl(i).obsolete_date IS NOT NULL
	THEN
	    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).revision_date
	    THEN
	    	FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_REVDT');
	        FND_MSG_PUB.ADD;
	    END IF;

	/* Removing following validations too for FP for bug 5930628
	    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).approved_date
	    THEN
	    	FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_APVDT');
	    	FND_MSG_PUB.ADD;
	    END IF;

	    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).effective_date
	    THEN
	    	FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_EFFDT');
	    	FND_MSG_PUB.ADD;
	    END IF;

	    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).issue_date
	    THEN
	    	FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_ISSDT');
	        FND_MSG_PUB.ADD;
	    END IF;

	    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).received_date
	    THEN
	        FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_RECDT');
	        FND_MSG_PUB.ADD;
	    END IF;
	*/
	END IF;
	-- if REVISION_STATUS_CODE == OBSOLETE and obsolete date is null then set it to sysdate.

	IF p_x_revision_tbl(i).revision_status_code IS NOT NULL AND
	p_x_revision_tbl(i).revision_status_code = 'OBSOLETE'
	THEN
	  SELECT TRUNC(SYSDATE) into p_x_revision_tbl(i).obsolete_date FROM DUAL;
	      -- truncate time stamp
	END IF;



        l_revision_tbl(i).doc_revision_id       := p_x_revision_tbl(i).doc_revision_id;

        l_revision_tbl(i).approved_by_party_id  := p_x_revision_tbl(i).approved_by_party_id;

        l_revision_tbl(i).document_id           := p_x_revision_tbl(i).document_id;
        l_revision_tbl(i).revision_no           := p_x_revision_tbl(i).revision_no;
        l_revision_tbl(i).revision_date         := p_x_revision_tbl(i).revision_date;
        l_revision_tbl(i).approved_date         := p_x_revision_tbl(i).approved_date;
        l_revision_tbl(i).effective_date        := p_x_revision_tbl(i).effective_date;
        l_revision_tbl(i).obsolete_date         := p_x_revision_tbl(i).obsolete_date;
        l_revision_tbl(i).issue_date            := p_x_revision_tbl(i).issue_date;
        l_revision_tbl(i).received_date         := p_x_revision_tbl(i).received_date;
        l_revision_tbl(i).url                   := p_x_revision_tbl(i).url;
        l_revision_tbl(i).volume                := p_x_revision_tbl(i).volume;
        l_revision_tbl(i).issue                 := p_x_revision_tbl(i).issue;
        l_revision_tbl(i).issue_number          := p_x_revision_tbl(i).issue_number;
        l_revision_tbl(i).language              := p_x_revision_tbl(i).language;
        l_revision_tbl(i).source_lang           := p_x_revision_tbl(i).source_lang;
        l_revision_tbl(i).comments              := p_x_revision_tbl(i).comments;
        l_revision_tbl(i).attribute_category    := p_x_revision_tbl(i).attribute_category;
        l_revision_tbl(i).attribute1            := p_x_revision_tbl(i).attribute1;
        l_revision_tbl(i).attribute2            := p_x_revision_tbl(i).attribute2;
        l_revision_tbl(i).attribute3            := p_x_revision_tbl(i).attribute3;
        l_revision_tbl(i).attribute4            := p_x_revision_tbl(i).attribute4;
        l_revision_tbl(i).attribute5            := p_x_revision_tbl(i).attribute5;
        l_revision_tbl(i).attribute6            := p_x_revision_tbl(i).attribute6;
        l_revision_tbl(i).attribute7            := p_x_revision_tbl(i).attribute7;
        l_revision_tbl(i).attribute8            := p_x_revision_tbl(i).attribute8;
        l_revision_tbl(i).attribute9            := p_x_revision_tbl(i).attribute9;
        l_revision_tbl(i).attribute10           := p_x_revision_tbl(i).attribute10;
        l_revision_tbl(i).attribute11           := p_x_revision_tbl(i).attribute11;
        l_revision_tbl(i).attribute12           := p_x_revision_tbl(i).attribute12;
        l_revision_tbl(i).attribute13           := p_x_revision_tbl(i).attribute13;
        l_revision_tbl(i).attribute14           := p_x_revision_tbl(i).attribute14;
        l_revision_tbl(i).attribute15           := p_x_revision_tbl(i).attribute15;
        l_revision_tbl(i).delete_flag           := p_x_revision_tbl(i).delete_flag;
        l_revision_tbl(i).object_version_number := p_x_revision_tbl(i).object_version_number;

   -- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
 END LOOP;
END IF;


/*----------------------------------------------------------------- */
/* procedure name: AHL_DI_DOC_REVISION_CUHK.CREATE_REVISION_PRE	    */
/*		   AHL_DI_DOC_REVISION_VUHK.CREATE_REVISION_PRE     */
/* description   : Added by Siddhartha to call User Hooks  	    */
/*      Date     : Dec 27 2001                                      */
/*----------------------------------------------------------------- */


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_REVISION_PUB','CREATE_REVISION',
					'B', 'C' )  then


IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_REVISION_CUHK.CREATE_REVISION_PRE');

	END IF;

AHL_DI_DOC_REVISION_CUHK.CREATE_REVISION_PRE
(

	 p_x_revision_tbl	     =>		l_revision_tbl ,
	 x_return_status             =>		l_return_status,
	 x_msg_count                 =>		l_msg_count   ,
	 x_msg_data                  =>		l_msg_data
);


   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'end AHL_DI_DOC_REVISION_CUHK.CREATE_REVISION_PRE');

	END IF;


      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_REVISION_PUB','CREATE_REVISION',
					'B', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_REVISION_VUHK.CREATE_REVISION_PRE');

	END IF;

AHL_DI_DOC_REVISION_VUHK.CREATE_REVISION_PRE(
			p_x_revision_tbl     	=>	l_revision_tbl ,
			X_RETURN_STATUS        	=>	l_return_status       ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );


IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_REVISION_VUHK.CREATE_REVISION_PRE');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;



END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                        */
/*---------------------------------------------------------*/


  -- Call the Private API
   AHL_DI_DOC_REVISION_PVT.CREATE_REVISION
                        (
                         p_api_version      => 1.0,
                         p_init_msg_list    => p_init_msg_list,
                         p_commit           => p_commit,
                         p_validate_only    => p_validate_only,
                         p_validation_level => p_validation_level,
                         p_x_revision_tbl   => l_revision_tbl,
                         x_return_status    => l_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data
                         );

   -- Standard call to get message count and if count is  get message info.

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
       FOR i IN 1..l_revision_tbl.COUNT
       LOOP
        p_x_revision_tbl(i).doc_revision_id := l_revision_tbl(i).doc_revision_id;
       END LOOP;
   END IF;



/*-----------------------------------------------------------------------------	*/
/* procedure name: AHL_DI_DOC_REVISION_VUHK.CREATE_REVISION_POST		*/
/*		   AHL_DI_DOC_REVISION_CUHK.CREATE_REVISION_POST		*/
/*        									*/
/* description   :  Added by siddhartha to call User Hooks   			*/
/*      Date     : Dec 27 2001                             			*/
/*------------------------------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_REVISION_PUB','CREATE_REVISION',
					'A', 'V' )  then

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_REVISION_VUHK.CREATE_REVISION_POST');

	END IF;

            AHL_DI_DOC_REVISION_VUHK.CREATE_REVISION_POST(
			p_revision_tbl	=>	l_revision_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End  AHL_DI_DOC_REVISION_VUHK.CREATE_REVISION_POST');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_REVISION_PUB','CREATE_REVISION',
					'A', 'C' )  then

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_REVISION_CUHK.CREATE_REVISION_POST');

	END IF;

              AHL_DI_DOC_REVISION_CUHK.CREATE_REVISION_POST(

			p_revision_tbl	=>		l_revision_tbl ,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_REVISION_CUHK.CREATE_REVISION_POST');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

END IF;



/*---------------------------------------------------------*/
/*     End ; Date     : Dec 27 2001                        */
/*---------------------------------------------------------*/



   -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Create Revision','+REV+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

   x_msg_data := 'tHIS IS A cHECK'||TO_CHAR(p_x_revision_tbl(1).approved_by_party_id);
EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO create_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pub.Create Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_revision;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pub.Create Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;


 WHEN OTHERS THEN
    ROLLBACK TO create_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_REVISION_PUB',
                            p_procedure_name  =>  'CREATE_REVISION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pub.Create Revision','+REV+');

        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

END CREATE_REVISION;
/*---------------------------------------------------*/
/* procedure name: modify_revision                  */
/* description :  Update the existing revision record*/
/*                                                   */
/*---------------------------------------------------*/

PROCEDURE MODIFY_REVISION
(
 p_api_version              IN      NUMBER    :=  1.0                ,
 p_init_msg_list            IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                   IN      VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only            IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level         IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_revision_tbl           IN  OUT NOCOPY revision_tbl              ,
 p_module_type              IN      VARCHAR2,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2
)
IS


CURSOR get_party_name(c_approved_by_pty_name IN VARCHAR2)
 IS
--Modified pjha:07-Aug-2002 for performance
 /*
SELECT party_id
  FROM ahl_hz_per_employees_v
 WHERE upper(party_name) = upper(c_approved_by_pty_name);
 */
 --changes due to performance pbarman 7.5.2003
 SELECT party_id
 FROM hz_parties
 WHERE upper(PARTY_NAME) = upper(c_approved_by_pty_name)
 AND AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PER') IN ('N','L')
 AND party_type = 'PERSON'
 UNION
 SELECT person_id
 FROM per_people_f ppf,per_person_types ppt
 WHERE upper(FULL_NAME) = upper(c_approved_by_pty_name)
 AND trunc(sysdate) BETWEEN effective_start_date AND effective_end_date
 AND nvl(current_employee_flag, 'X') = 'Y'
 AND ppf.person_type_id = ppt.person_type_id
 AND system_person_type = 'EMP'
 AND AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PER') IN ('I','S');

-- Check for ID
CURSOR approved_by_party_id(c_approved_by_pty_id  IN NUMBER)
 IS
SELECT party_id
  FROM hz_parties
 WHERE party_id = c_approved_by_pty_id;

--Check for Name
CURSOR approved_by_party_desc(c_approved_by_pty_name  IN VARCHAR2)
 IS
SELECT party_id
  FROM hz_parties
 WHERE UPPER(party_name) = UPPER(c_approved_by_pty_name);

  --Used to retrieve the party id for party name and party id
   CURSOR get_party_name_id (c_party_name  IN VARCHAR2, c_party_id IN NUMBER)
   IS
   SELECT person_id
   FROM per_people_f ppf, per_person_types ppt
   WHERE upper(FULL_NAME) = upper(c_party_name)
     AND ppf.person_id = c_party_id
     AND trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
     AND nvl(ppf.current_employee_flag,'x') = 'Y'
     AND ppf.person_type_id = ppt.person_type_id
     AND ppt.system_person_type ='EMP';

    -- FP For Bug #8410484
    CURSOR get_current_effective_date (c_doc_revision_id NUMBER,c_document_id NUMBER)
    IS
    SELECT effective_date
    FROM AHL_DOC_REVISIONS_B
    WHERE doc_revision_id = c_doc_revision_id
    AND document_id = c_document_id;
   --FP end



--
 l_api_name     CONSTANT VARCHAR2(30) := 'MODIFY_REVISION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_revision_type_code    VARCHAR2(30);
 l_media_type_code       VARCHAR2(30);
 l_revision_status_code  VARCHAR2(30);
 l_approved_by_party_id  NUMBER;
 l_revision_tbl          AHL_DI_DOC_REVISION_PVT.revision_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;
 l_sysdate                DATE;
 l_current_revision_date  DATE;
 l_current_effective_date DATE;


BEGIN
    -- Standard Start of API savepoint
     SAVEPOINT modify_revision;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_revision_pub.Modify Revision','+REV+');

	END IF;
    END IF;
    -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := 'S';
    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --Start API Body
   IF p_x_revision_tbl.COUNT > 0
   THEN
     FOR i IN p_x_revision_tbl.FIRST..p_x_revision_tbl.LAST
     LOOP

         --For Approved by Party Id, Party Name is present
           IF (p_x_revision_tbl(i).approved_by_pty_name IS NOT NULL)
              THEN



             IF ahl_di_doc_index_pvt.get_product_install_status('PER') in ('N','L')
             	THEN
     	            OPEN  approved_by_party_desc(p_x_revision_tbl(i).approved_by_pty_name);
     	            FETCH approved_by_party_desc INTO l_approved_by_party_id;
     		            IF approved_by_party_desc%FOUND
     		            THEN
     		             p_x_revision_tbl(i).approved_by_party_id := l_approved_by_party_id;
     		             ELSE
     		              FND_MESSAGE.SET_NAME('AHL','AHL_DI_APP_BY_PTY_ID_NOT_EXIST');
     		              FND_MSG_PUB.ADD;
     		            END IF;
     	            CLOSE approved_by_party_desc;


             ELSIF ahl_di_doc_index_pvt.get_product_install_status('PER') in ('I','S')
             THEN

             	-- modified for bugfix 2193744

		      OPEN get_party_name_id (p_x_revision_tbl(i).approved_by_pty_name, p_x_revision_tbl(i).approved_by_party_id);
	              FETCH get_party_name_id INTO l_approved_by_party_id;

	              -- If 1 record retrieved then party id and name match, use party id
	              p_x_revision_tbl(i).approved_by_party_id := l_approved_by_party_id;


	              -- If no records, then party name has been changed
	              IF get_party_name_id%NOTFOUND THEN


                     		  IF p_x_revision_tbl(i).APPROVED_BY_PARTY_ID IS NULL THEN
		 			     p_x_revision_tbl(i).approved_by_party_id := null;
		   	  	  END IF;


						OPEN get_party_name(p_x_revision_tbl(i).approved_by_pty_name);
		 		     		   LOOP
		 		    			    FETCH get_party_name INTO l_approved_by_party_id;
		 		    			    EXIT WHEN get_party_name%NOTFOUND;
		 		    		   END LOOP;

		 		    		  IF get_party_name%ROWCOUNT = 0 THEN
		 		    			  FND_MESSAGE.SET_NAME('AHL','AHL_DI_APP_BY_PTY_ID_NOT_EXIST');
		 		    			  FND_MSG_PUB.ADD;
		 		    		  ELSIF get_party_name%ROWCOUNT = 1 THEN
		 		    			  p_x_revision_tbl(i).approved_by_party_id := l_approved_by_party_id;
		 		    		  ELSE
		 		    		  -- It will show the message to use LOV , so it would take care
		 		    		  -- for duplicate records as well


		 		    			    FND_MESSAGE.SET_NAME('AHL','AHL_DI_APPROVED_BY_USE_LOV');
		 					    FND_MSG_PUB.ADD;

		 		    		  END IF;
		 		     		  CLOSE get_party_name;
				   END IF;
                     		   CLOSE get_party_name_id;


          -- modified for bugfix 2193744
          END IF;


          /* If Party Name is not available then set the Party Id also to null */
            ELSE
              --Party Name is missing

               	   p_x_revision_tbl(i).approved_by_party_id := NULL;

            END IF;
         --For Revision Type Code
       IF p_x_revision_tbl(i).revision_type_desc IS NOT NULL
       THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_REVISION_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_revision_tbl(i).revision_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).revision_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
         -- If Code is present
        IF p_x_revision_tbl(i).revision_type_code IS NOT NULL
         THEN
           l_revision_tbl(i).revision_type_code := p_x_revision_tbl(i).revision_type_code;
        --If both are missing
        ELSE
           l_revision_tbl(i).revision_type_code := p_x_revision_tbl(i).revision_type_code;
        END IF;
        --For Media Type Code, meaning is present
        IF p_x_revision_tbl(i).media_type_desc IS NOT NULL
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_MEDIA_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_revision_tbl(i).media_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).media_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_MEDTYP_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
         -- If ID presnt
        IF p_x_revision_tbl(i).media_type_code IS NOT NULL
         THEN
           l_revision_tbl(i).media_type_code := p_x_revision_tbl(i).media_type_code;
         --Both are missing
         ELSE
           l_revision_tbl(i).media_type_code := p_x_revision_tbl(i).media_type_code;
         END IF;

         --For Revision Status Code
         IF p_x_revision_tbl(i).revision_status_desc IS NOT NULL
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_REVISION_STATUS_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_revision_tbl(i).revision_status_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).revision_status_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_STAT_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- If Revision status code presents
         IF p_x_revision_tbl(i).revision_status_code IS NOT NULL
         THEN
           l_revision_tbl(i).revision_status_code := p_x_revision_tbl(i).revision_status_code;
         ELSE
          --Both are missing
           l_revision_tbl(i).revision_status_code := p_x_revision_tbl(i).revision_status_code;
         END IF;
        --

        --validations put for enhancements
	-- Enhancement no #2027019: pbarman : April 2003
	--if rev date is null then rev date = sysdate.

		IF p_x_revision_tbl(i).revision_date IS NULL OR p_x_revision_tbl(i).revision_date = FND_API.G_MISS_DATE
		THEN
		    FND_MESSAGE.SET_NAME('AHL','AHL_DI_REVDT_NULL');
	            FND_MSG_PUB.ADD;
		ELSE
		-- select the current revision date. the edited date cannot be less than that.
		    SELECT REVISION_DATE INTO l_current_revision_date from
		    ahl_doc_revisions_b
		    where
		    ahl_doc_revisions_b.doc_revision_id = p_x_revision_tbl(i).doc_revision_id
		    and
		    ahl_doc_revisions_b.document_id = p_x_revision_tbl(i).document_id;

		    IF p_x_revision_tbl(i).revision_date < l_current_revision_date
		    THEN
		      FND_MESSAGE.SET_NAME('AHL','AHL_DI_REVDT_LESS_PREVDATE');
	              FND_MSG_PUB.ADD;
	            END IF;
	END IF;
/* Vineet - FP for Bug 5930628 - Removing all date validations as per PM discussion
	--if approved_date < revision_date then error

	IF p_x_revision_tbl(i).approved_date IS NOT NULL
	THEN
	   IF p_x_revision_tbl(i).approved_date < p_x_revision_tbl(i).revision_date
	   THEN
	       FND_MESSAGE.SET_NAME('AHL','AHL_DI_APVDT_LESS_REVDT');
               FND_MSG_PUB.ADD;
	   END IF;
	END IF;

	--if( issue date  <  either of (approved date,revision date)) then error.

	-- bug 3662906
        IF p_x_revision_tbl(i).issue_date IS NOT NULL
	THEN
	  IF p_x_revision_tbl(i).issue_date < nvl(p_x_revision_tbl(i).approved_date, p_x_revision_tbl(i).revision_date)
	  THEN
				IF p_x_revision_tbl(i).approved_date IS NULL
					THEN
							FND_MESSAGE.SET_NAME('AHL', 'AHL_DI_ISSDT_LESS_REVDT');
       FND_MSG_PUB.ADD;
					ELSE
	     FND_MESSAGE.SET_NAME('AHL','AHL_DI_ISSDT_LESS_APVDT');
             FND_MSG_PUB.ADD;
					END IF;
	  END IF;

	END IF;

        --if(effective date <  either of  (approved date, revision date))

        IF p_x_revision_tbl(i).effective_date IS NOT NULL
	THEN

	  IF p_x_revision_tbl(i).effective_date < nvl(p_x_revision_tbl(i).approved_date, p_x_revision_tbl(i).revision_date)
	  THEN
			IF p_x_revision_tbl(i).approved_date IS NULL
					THEN
							FND_MESSAGE.SET_NAME('AHL','AHL_DI_EFFDT_LESS_REVDT');
       FND_MSG_PUB.ADD;
					ELSE
	     FND_MESSAGE.SET_NAME('AHL','AHL_DI_EFFDT_LESS_APVDT');
             FND_MSG_PUB.ADD;
					END IF;
	  END IF;
	END IF;

	--if(received_date > revision_date)

	IF p_x_revision_tbl(i).received_date IS NOT NULL
	THEN
	  IF p_x_revision_tbl(i).received_date > p_x_revision_tbl(i).revision_date
          THEN
	     FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECDT_GT_REVDT');
             FND_MSG_PUB.ADD;
	  END IF;
	END IF;
*/
  	-- if obsolete date is not null, check if it is less than any other date
		IF p_x_revision_tbl(i).obsolete_date IS NOT NULL
		THEN
		    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).revision_date
		    THEN
		    	FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_REVDT');
		        FND_MSG_PUB.ADD;
		    END IF;

		/* IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).approved_date
		    THEN
		    	FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_APVDT');
		    	FND_MSG_PUB.ADD;
		    END IF;

		    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).effective_date
		    THEN
		    	FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_EFFDT');
		    	FND_MSG_PUB.ADD;
		    END IF;

		    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).issue_date
		    THEN
		    	FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_ISSDT');
		        FND_MSG_PUB.ADD;
		    END IF;

		    IF p_x_revision_tbl(i).obsolete_date < p_x_revision_tbl(i).received_date
		    THEN
		        FND_MESSAGE.SET_NAME('AHL','AHL_DI_OBSDT_LT_RECDT');
		        FND_MSG_PUB.ADD;
		    END IF;
		*/
	END IF;
  	-- if REVISION_STATUS_CODE == OBSOLETE and obsolete date is null then set it to sysdate.

	IF p_x_revision_tbl(i).revision_status_code IS NOT NULL AND
	p_x_revision_tbl(i).revision_status_code = 'OBSOLETE'
	THEN
	 --   IF p_x_revision_tbl(i).obsolete_date IS NULL
	  --  THEN
	        SELECT TRUNC(SYSDATE) into p_x_revision_tbl(i).obsolete_date FROM DUAL;
	         -- truncate time stamp
	   -- END IF;
	END IF;

	-- FP for Bug #8410484
	    OPEN get_current_effective_date(p_x_revision_tbl(i).doc_revision_id,p_x_revision_tbl(i).document_id);
	    FETCH get_current_effective_date INTO l_current_effective_date;
	    CLOSE get_current_effective_date;
  	    IF l_current_effective_date > p_x_revision_tbl(i).effective_date THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_EFFDT_LESS_PREVDATE');
		FND_MSG_PUB.ADD;
	    END IF;
	-- FP end

        l_revision_tbl(i).doc_revision_id      := p_x_revision_tbl(i).doc_revision_id;

        l_revision_tbl(i).approved_by_party_id := p_x_revision_tbl(i).approved_by_party_id;

        l_revision_tbl(i).document_id          := p_x_revision_tbl(i).document_id;
        l_revision_tbl(i).revision_no          := p_x_revision_tbl(i).revision_no;
        l_revision_tbl(i).revision_date        := p_x_revision_tbl(i).revision_date;
        l_revision_tbl(i).approved_date        := p_x_revision_tbl(i).approved_date;
        l_revision_tbl(i).effective_date       := p_x_revision_tbl(i).effective_date;
        l_revision_tbl(i).obsolete_date        := p_x_revision_tbl(i).obsolete_date;
        l_revision_tbl(i).issue_date           := p_x_revision_tbl(i).issue_date;
        l_revision_tbl(i).received_date        := p_x_revision_tbl(i).received_date;
        l_revision_tbl(i).url                  := p_x_revision_tbl(i).url;
        l_revision_tbl(i).volume               := p_x_revision_tbl(i).volume;
        l_revision_tbl(i).issue                := p_x_revision_tbl(i).issue;
        l_revision_tbl(i).issue_number         := p_x_revision_tbl(i).issue_number;
        l_revision_tbl(i).language             := p_x_revision_tbl(i).language;
        l_revision_tbl(i).source_lang          := p_x_revision_tbl(i).source_lang;
        l_revision_tbl(i).comments             := p_x_revision_tbl(i).comments;
        l_revision_tbl(i).attribute_category   := p_x_revision_tbl(i).attribute_category;
        l_revision_tbl(i).attribute1           := p_x_revision_tbl(i).attribute1;
        l_revision_tbl(i).attribute2           := p_x_revision_tbl(i).attribute2;
        l_revision_tbl(i).attribute3           := p_x_revision_tbl(i).attribute3;
        l_revision_tbl(i).attribute4           := p_x_revision_tbl(i).attribute4;
        l_revision_tbl(i).attribute5           := p_x_revision_tbl(i).attribute5;
        l_revision_tbl(i).attribute6           := p_x_revision_tbl(i).attribute6;
        l_revision_tbl(i).attribute7           := p_x_revision_tbl(i).attribute7;
        l_revision_tbl(i).attribute8           := p_x_revision_tbl(i).attribute8;
        l_revision_tbl(i).attribute9           := p_x_revision_tbl(i).attribute9;
        l_revision_tbl(i).attribute10          := p_x_revision_tbl(i).attribute10;
        l_revision_tbl(i).attribute11          := p_x_revision_tbl(i).attribute11;
        l_revision_tbl(i).attribute12          := p_x_revision_tbl(i).attribute12;
        l_revision_tbl(i).attribute13          := p_x_revision_tbl(i).attribute13;
        l_revision_tbl(i).attribute14          := p_x_revision_tbl(i).attribute14;
        l_revision_tbl(i).attribute15          := p_x_revision_tbl(i).attribute15;
        l_revision_tbl(i).delete_flag          := p_x_revision_tbl(i).delete_flag;
        l_revision_tbl(i).object_version_number := p_x_revision_tbl(i).object_version_number;

   -- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
 END LOOP;
END IF;



/*---------------------------------------------------------------*/
/* procedure name: AHL_DI_DOC_REVISION_CUHK.MODIFY_REVISION_PRE  */
/*		   AHL_DI_DOC_REVISION_VUHK.MODIFY_REVISION_PRE  */
/* description   : Added by Siddhartha to call User Hooks  	 */
/*      Date     : Dec 27 2001                             	 */
/*---------------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_REVISION_PUB','MODIFY_REVISION',
					'B', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_REVISION_CUHK.MODIFY_REVISION_PRE');

	END IF;

 AHL_DI_DOC_REVISION_CUHK.MODIFY_REVISION_PRE
(

	 p_x_revision_tbl	     =>		l_revision_tbl ,
	 x_return_status             =>		l_return_status,
	 x_msg_count                 =>		l_msg_count,
	 x_msg_data                  =>		l_msg_data
);


   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_REVISION_CUHK.MODIFY_REVISION_PRE');

	END IF;

  IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_REVISION_PUB','MODIFY_REVISION',
					'B', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_REVISION_VUHK.MODIFY_REVISION_PRE');

	END IF;


AHL_DI_DOC_REVISION_VUHK.MODIFY_REVISION_PRE(
			p_x_revision_tbl     	=>	l_revision_tbl ,
			X_RETURN_STATUS        	=>	l_return_status       ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );


      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_REVISION_VUHK.MODIFY_REVISION_PRE');

	END IF;

END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                        */
/*---------------------------------------------------------*/

  -- Call the Private API
   AHL_DI_DOC_REVISION_PVT.MODIFY_REVISION
                        (
                         p_api_version      => 1.0,
                         p_init_msg_list    => l_init_msg_list,
                         p_commit           => p_commit,
                         p_validate_only    => p_validate_only,
                         p_validation_level => p_validation_level,
                         p_x_revision_tbl   => l_revision_tbl,
                         x_return_status    => l_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data
                         );
   -- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;



/*-----------------------------------------------------------------------------	*/
/* procedure name: AHL_DI_DOC_REVISION_VUHK.MODIFY_REVISION_POST		*/
/*		   AHL_DI_DOC_REVISION_CUHK.MODIFY_REVISION_POST		*/
/*        									*/
/* description   :  Added by siddhartha to call User Hooks   			*/
/*      Date     : Dec 27 2001                             			*/
/*------------------------------------------------------------------------------*/



IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_REVISION_PUB','MODIFY_REVISION',
					'A', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_REVISION_VUHK.MODIFY_REVISION_POST');

	END IF;

            AHL_DI_DOC_REVISION_VUHK.MODIFY_REVISION_POST(
			p_revision_tbl		=>	l_revision_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );


   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_REVISION_VUHK.MODIFY_REVISION_POST');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;


END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_REVISION_PUB','MODIFY_REVISION',
					'A', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_REVISION_CUHK.MODIFY_REVISION_POST');

	END IF;

            AHL_DI_DOC_REVISION_CUHK.MODIFY_REVISION_POST(

			p_revision_tbl	=>		l_revision_tbl ,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_REVISION_CUHK.MODIFY_REVISION_POST');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 27 2001                        */
/*---------------------------------------------------------*/



    -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Modify Revision','+REV+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

   x_msg_data := 'tHIS IS A cHECK'||TO_CHAR(p_x_revision_tbl(1).approved_by_party_id);

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pub.Modify Revision','+REV+');

        -- Check if API is called in debug mode. If yes, disable debug.
          AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_revision;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pub.Modify Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_revision;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_REVISION_PUB',
                            p_procedure_name  =>  'MODIFY_REVISION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_revision_pub.Modify Revision','+REV+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

END MODIFY_REVISION;
END AHL_DI_DOC_REVISION_PUB;

/
