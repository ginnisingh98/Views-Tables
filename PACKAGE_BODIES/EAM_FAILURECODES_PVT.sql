--------------------------------------------------------
--  DDL for Package Body EAM_FAILURECODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_FAILURECODES_PVT" AS
/* $Header: EAMVFCPB.pls 120.0 2006/03/08 07:10:39 sshahid noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):='EAM_FailureCodes_PVT';

G_LOCKROW_EXCEPTION EXCEPTION;
PRAGMA EXCEPTION_INIT (G_LOCKROW_EXCEPTION,-54);

-- Procedure for raising errors
PROCEDURE Raise_Error (p_error VARCHAR2, p_token VARCHAR2, p_token_value VARCHAR2)
IS
BEGIN

  FND_MESSAGE.SET_NAME ('EAM', p_error);
  IF (p_token IS NOT NULL) THEN
     FND_MESSAGE.SET_TOKEN (p_token, p_token_value);
  END IF;
  FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
END Raise_Error;

-- Procedure to Validate Code Info passed in various modes
-- to Setup_Code API
PROCEDURE Validate_Code
          (p_mode             IN VARCHAR2,
           p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL   ,
           p_failurecode_rec  IN EAM_FailureCodes_PUB.eam_failurecode_rec_type)
IS
l_code_exists  NUMBER;
l_eff_end_date DATE;
l_code_in_use  NUMBER;

BEGIN

     IF (p_failurecode_rec.code_type IS NULL OR
         p_failurecode_rec.code IS NULL) THEN
         Raise_Error ('EAM_FAILURECODE_MANDATORY', 'MAND_PARAM', 'code or code type');
     END IF;

     IF (p_failurecode_rec.code_type NOT IN
         (EAM_FailureCodes_PUB.G_FAILURE_CODE,
          EAM_FailureCodes_PUB.G_CAUSE_CODE,
          EAM_FailureCodes_PUB.G_RESOLUTION_CODE)) THEN
          Raise_Error ('EAM_FAILURECODE_TYPE_INVALID','CODE_TYPE', p_failurecode_rec.code_type);
     END IF;

     l_code_exists := 0;
     BEGIN
        IF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_FAILURE_CODE) THEN
           SELECT effective_end_date
             INTO l_eff_end_date
             FROM eam_failure_codes
            WHERE failure_code = p_failurecode_rec.code;
        ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_CAUSE_CODE) THEN
           SELECT effective_end_date
             INTO l_eff_end_date
             FROM eam_cause_codes
            WHERE cause_code = p_failurecode_rec.code;
        ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_RESOLUTION_CODE) THEN
           SELECT effective_end_date
             INTO l_eff_end_date
             FROM eam_resolution_codes
            WHERE resolution_code = p_failurecode_rec.code;
        END IF;

        l_code_exists := SQL%ROWCOUNT;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_code_exists := 0;
     END;

     IF (p_mode = 'C' AND l_code_exists > 0) THEN
         Raise_Error ('EAM_FAILURECODE_EXISTS', 'FAILURE_CODE', p_failurecode_rec.code);

     ELSIF (p_mode = 'U') THEN

         IF (l_code_exists = 0) THEN
            Raise_Error ('EAM_FAILURECODE_NOT_EXISTS', 'FAILURE_CODE', p_failurecode_rec.code);
         END IF;

        /*
         IF (l_eff_end_date IS NOT NULL AND
             TRUNC(SYSDATE) > TRUNC(l_eff_end_date)) THEN
	    Raise_Error ('EAM_FAILURECODE_INACTIVE');
	 END IF;
        */

     ELSIF (p_mode = 'D') THEN

         IF (l_code_exists = 0) THEN
            Raise_Error ('EAM_FAILURECODE_NOT_EXISTS','FAILURE_CODE', p_failurecode_rec.code);
         END IF;

         l_code_in_use := 0;

         IF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_FAILURE_CODE) THEN
            SELECT count(1)
              INTO l_code_in_use
              FROM eam_failure_combinations
             WHERE failure_code = p_failurecode_rec.code
               AND rownum < 2;
         ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_CAUSE_CODE) THEN
            SELECT count(1)
              INTO l_code_in_use
              FROM eam_failure_combinations
             WHERE cause_code = p_failurecode_rec.code
               AND rownum < 2;
         ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_RESOLUTION_CODE) THEN
            SELECT count(1)
              INTO l_code_in_use
              FROM eam_failure_combinations
             WHERE resolution_code = p_failurecode_rec.code
               AND rownum < 2;
         END IF;

         IF (l_code_in_use > 0) THEN
            Raise_Error ('EAM_FAILURECODE_USED','FAILURE_CODE', p_failurecode_rec.code);
         END IF;
     END IF;
END Validate_Code;

-- Procedure to Validate Code Combination Info passed in various modes
-- to Setup_Combination API
PROCEDURE Validate_Combination
          (p_mode              IN VARCHAR2,
           p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL   ,
           p_combination_rec   IN EAM_FailureCodes_PUB.eam_combination_rec_type,
           x_set_id            OUT NOCOPY NUMBER,
           x_failure_exists    OUT NOCOPY NUMBER,
           x_cause_exists      OUT NOCOPY NUMBER,
           x_resolution_exists OUT NOCOPY NUMBER,
           x_combination_id    OUT NOCOPY NUMBER)
IS

l_set_id                 NUMBER;
l_failure_exists         NUMBER;
l_cause_exists           NUMBER;
l_resolution_exists      NUMBER;
l_set_end_date           DATE;
l_combination_exists     NUMBER;
l_failure_end_date       DATE;
l_cause_end_date         DATE;
l_resolution_end_date    DATE;
l_combination_id         NUMBER;
l_combination_used       NUMBER;

BEGIN
      -- Ensure mandatory parameters are there
      IF (p_combination_rec.failure_code IS NULL OR
          p_combination_rec.cause_code IS NULL OR
          p_combination_rec.resolution_code IS NULL) THEN
          Raise_Error ('EAM_FAILURECODE_MANDATORY','MAND_PARAM','failure code or cause code or resolution code');
      END IF;

      -- Validate Failure Set
      IF (p_combination_rec.set_id IS NOT NULL) THEN
            l_set_id := p_combination_rec.set_id;
      ELSIF (p_combination_rec.set_name IS NOT NULL) THEN
            SELECT min(set_id)
              INTO l_set_id
              FROM eam_failure_sets
             WHERE set_name = p_combination_rec.set_name;

             IF (l_set_id IS NULL) THEN
                Raise_Error ('EAM_FAILURESET_INVALID', 'FAILURE_SET', p_combination_rec.set_name);
             END IF;
      ELSE
             Raise_Error ('EAM_FAILURESET_INVALID',NULL, NULL);
      END IF;

      SELECT min(effective_end_date)
        INTO l_set_end_date
        FROM eam_failure_sets
       WHERE set_id = l_set_id;

      IF (l_set_end_date IS NOT NULL AND
             TRUNC(SYSDATE) > TRUNC(l_set_end_date)) THEN
             Raise_Error ('EAM_FAILURESET_INACTIVE', 'FAILURE_SET', l_set_id || ' - ' || p_combination_rec.set_name);
      END IF;

      x_set_id := l_set_id;

      -- Validate Failure, Cause and Resolution Codes
      l_failure_exists    := 1;
      l_cause_exists      := 1;
      l_resolution_exists := 1;

      BEGIN
         SELECT effective_end_date
           INTO l_failure_end_date
           FROM eam_failure_codes
          WHERE failure_code = p_combination_rec.failure_code;
          l_failure_exists := SQL%ROWCOUNT;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
      	      l_failure_exists := 0;
      END;

      BEGIN
         SELECT effective_end_date
           INTO l_cause_end_date
           FROM eam_cause_codes
          WHERE cause_code = p_combination_rec.cause_code;
          l_cause_exists := SQL%ROWCOUNT;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
      	      l_cause_exists := 0;
      END;

      BEGIN
         SELECT effective_end_date
           INTO l_resolution_end_date
           FROM eam_resolution_codes
          WHERE resolution_code = p_combination_rec.resolution_code;
          l_resolution_exists := SQL%ROWCOUNT;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_resolution_exists := 0;
      END;

      x_failure_exists    := l_failure_exists ;
      x_cause_exists      := l_cause_exists   ;
      x_resolution_exists := l_resolution_exists;

      l_combination_exists := 0;

      IF (p_combination_rec.combination_id IS NOT NULL) THEN
         SELECT count(1)
	   INTO l_combination_exists
	   FROM eam_failure_combinations
	  WHERE combination_id = p_combination_rec.combination_id;
	  l_combination_id := p_combination_rec.combination_id;
      ELSE
        BEGIN
           SELECT combination_id
             INTO l_combination_id
             FROM eam_failure_combinations
            WHERE set_id = l_set_id
              AND failure_code = p_combination_rec.failure_code
              AND cause_code = p_combination_rec.cause_code
              AND resolution_code = p_combination_rec.resolution_code;
           l_combination_exists := SQL%ROWCOUNT;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_combination_exists := 0;
        END;

      END IF;

      IF (p_mode = 'C') THEN

         IF (l_combination_exists > 0) THEN
            Raise_Error ('EAM_COMBINATION_EXISTS', 'COMBINATION', p_combination_rec.failure_code || ' - ' ||
                                                                   p_combination_rec.cause_code || ' - ' ||
                                                                   p_combination_rec.resolution_code);
         END IF;

         IF (l_failure_end_date IS NOT NULL AND
	      TRUNC(SYSDATE) > TRUNC(l_failure_end_date)) THEN
                Raise_Error ('EAM_FAILURECODE_INACTIVE','FAILURE_CODE',p_combination_rec.failure_code);
         END IF;

         IF  (l_cause_end_date IS NOT NULL AND
	      TRUNC(SYSDATE) > TRUNC(l_cause_end_date)) THEN
              Raise_Error ('EAM_FAILURECODE_INACTIVE','FAILURE_CODE',p_combination_rec.cause_code);
         END IF;

	 IF (l_resolution_end_date IS NOT NULL AND
	      TRUNC(SYSDATE) > TRUNC(l_resolution_end_date)) THEN
	        Raise_Error ('EAM_FAILURECODE_INACTIVE', 'FAILURE_CODE',p_combination_rec.resolution_code);
         END IF;

      ELSIF (p_mode = 'U') THEN

         IF (l_combination_exists = 0) THEN
            Raise_Error ('EAM_COMBINATION_INVALID', 'COMBINATION', p_combination_rec.failure_code || ' - ' ||
                                                                   p_combination_rec.cause_code || ' - ' ||
                                                                   p_combination_rec.resolution_code);
         END IF;

         IF (p_combination_rec.effective_end_date = FND_API.G_MISS_DATE) THEN

         IF (l_failure_end_date IS NOT NULL AND
	      TRUNC(SYSDATE) > TRUNC(l_failure_end_date)) THEN
                Raise_Error ('EAM_FAILURECODE_INACTIVE','FAILURE_CODE',p_combination_rec.failure_code);
         END IF;

         IF  (l_cause_end_date IS NOT NULL AND
	      TRUNC(SYSDATE) > TRUNC(l_cause_end_date)) THEN
              Raise_Error ('EAM_FAILURECODE_INACTIVE','FAILURE_CODE',p_combination_rec.cause_code);
         END IF;

	 IF (l_resolution_end_date IS NOT NULL AND
	      TRUNC(SYSDATE) > TRUNC(l_resolution_end_date)) THEN
	        Raise_Error ('EAM_FAILURECODE_INACTIVE', 'FAILURE_CODE',p_combination_rec.resolution_code);
         END IF;

         END IF;

      ELSIF (p_mode = 'D') THEN
         IF (l_combination_exists = 0) THEN
           SELECT min(combination_id)
             INTO l_combination_id
             FROM eam_failure_combinations
            WHERE set_id = l_set_id
              AND failure_code = p_combination_rec.failure_code
              AND cause_code = p_combination_rec.cause_code
              AND resolution_code = p_combination_rec.resolution_code;
         END IF;


         l_combination_used := 0;
            SELECT count(1)
              INTO l_combination_used
              FROM eam_asset_failure_codes
             WHERE combination_id = l_combination_id
               AND rownum < 2;

            IF (l_combination_used > 0) THEN
               Raise_Error ('EAM_COMBINATION_USED', 'COMBINATION', p_combination_rec.failure_code || ' - ' ||
                                                                   p_combination_rec.cause_code || ' - ' ||
                                                                   p_combination_rec.resolution_code);
            END IF;


      END IF;
      x_combination_id := l_combination_id;
END Validate_Combination;

PROCEDURE Setup_Code
         (p_api_version      IN  NUMBER                                     ,
          p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit           IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_validation_level IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL       ,
          p_mode             IN VARCHAR2                                    ,
          p_failurecode_rec  IN  EAM_FailureCodes_PUB.eam_failurecode_rec_type,
          x_return_status    OUT NOCOPY VARCHAR2                            ,
          x_msg_count        OUT NOCOPY NUMBER                              ,
          x_msg_data         OUT NOCOPY VARCHAR2
         )
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Setup_Code';
l_api_version   CONSTANT NUMBER       := 1.0;
l_code          VARCHAR2(80);

CURSOR lock_fc IS
SELECT description, effective_end_date
  FROM eam_failure_codes
 WHERE failure_code = l_code
   FOR UPDATE NOWAIT;

CURSOR lock_cc IS
SELECT description, effective_end_date
  FROM eam_cause_codes
 WHERE cause_code = l_code
   FOR UPDATE NOWAIT;

CURSOR lock_rc IS
SELECT description, effective_end_date
  FROM eam_resolution_codes
 WHERE resolution_code = l_code
   FOR UPDATE NOWAIT;

BEGIN
    -- API savepoint
    SAVEPOINT Setup_Code_PVT;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Failure Code Info passed
    Validate_Code(p_mode, p_validation_level, p_failurecode_rec);

    l_code := p_failurecode_rec.code;

    IF (p_mode = 'C') THEN

        IF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_FAILURE_CODE) THEN

	   -- Insert into eam failure codes
	   INSERT INTO eam_failure_codes
	               (failure_code      ,
                        description       ,
                        effective_end_date,
                        created_by        ,
                        creation_date     ,
                        last_update_date  ,
                        last_updated_by   ,
                        last_update_login)
                 VALUES (p_failurecode_rec.code          ,
                         p_failurecode_rec.description       ,
                         p_failurecode_rec.effective_end_date,
                         fnd_global.user_id,
                         SYSDATE,
                         SYSDATE,
                         fnd_global.user_id,
                         NULL);
        ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_CAUSE_CODE) THEN

	   -- Insert into eam cause codes
	   INSERT INTO eam_cause_codes
	               (cause_code      ,
                        description       ,
                        effective_end_date,
                        created_by        ,
                        creation_date     ,
                        last_update_date  ,
                        last_updated_by   ,
                        last_update_login)
                 VALUES (p_failurecode_rec.code              ,
                         p_failurecode_rec.description       ,
                         p_failurecode_rec.effective_end_date,
                         fnd_global.user_id,
                         SYSDATE,
                         SYSDATE,
                         fnd_global.user_id,
                         NULL);
        ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_RESOLUTION_CODE) THEN

	   -- Insert into eam resolution codes
	   INSERT INTO eam_resolution_codes
	               (resolution_code      ,
                        description       ,
                        effective_end_date,
                        created_by        ,
                        creation_date     ,
                        last_update_date  ,
                        last_updated_by   ,
                        last_update_login)
                 VALUES (p_failurecode_rec.code              ,
                         p_failurecode_rec.description       ,
                         p_failurecode_rec.effective_end_date,
                         fnd_global.user_id,
                         SYSDATE,
                         SYSDATE,
                         fnd_global.user_id,
                         NULL);
        END IF;

     ELSIF (p_mode = 'U') THEN

         IF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_FAILURE_CODE) THEN
             OPEN lock_fc;
             UPDATE eam_failure_codes
                SET description = decode(p_failurecode_rec.description,
                                         NULL,description,
                                         FND_API.G_MISS_CHAR, NULL,
                                         p_failurecode_rec.description),
                    effective_end_date = decode(
                                         p_failurecode_rec.effective_end_date,
                                         NULL,effective_end_date,
                                         FND_API.G_MISS_DATE,NULL,
                                         p_failurecode_rec.effective_end_date)
              WHERE failure_code = l_code;
              CLOSE lock_fc;
         ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_CAUSE_CODE) THEN
             OPEN lock_cc;
             UPDATE eam_cause_codes
                SET description = decode(p_failurecode_rec.description,
                                         NULL,description,
                                         FND_API.G_MISS_CHAR, NULL,
                                         p_failurecode_rec.description),
                    effective_end_date = decode(
                                         p_failurecode_rec.effective_end_date,
                                         NULL,effective_end_date,
                                         FND_API.G_MISS_DATE,NULL,
                                         p_failurecode_rec.effective_end_date)
              WHERE cause_code = l_code;
              CLOSE lock_cc;
         ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_RESOLUTION_CODE) THEN
             OPEN lock_rc;
             UPDATE eam_resolution_codes
                SET description = decode(p_failurecode_rec.description,
                                         NULL,description,
                                         FND_API.G_MISS_CHAR, NULL,
                                         p_failurecode_rec.description),
                    effective_end_date = decode(
                                         p_failurecode_rec.effective_end_date,
                                         NULL,effective_end_date,
                                         FND_API.G_MISS_DATE,NULL,
                                         p_failurecode_rec.effective_end_date)
              WHERE resolution_code = l_code;
              CLOSE lock_rc;
         END IF;

     ELSIF (p_mode = 'D') THEN

         IF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_FAILURE_CODE) THEN
             DELETE FROM eam_failure_codes
              WHERE failure_code = l_code;
         ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_CAUSE_CODE) THEN
             DELETE FROM eam_cause_codes
              WHERE cause_code = l_code;
         ELSIF (p_failurecode_rec.code_type = EAM_FailureCodes_PUB.G_RESOLUTION_CODE) THEN
             DELETE FROM eam_resolution_codes
              WHERE resolution_code = l_code;
         END IF;

     END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
    END IF;

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Setup_Code_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count     	,
                 p_data  => x_msg_data
    		);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Setup_Code_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
                 p_data  => x_msg_data
    		);
        WHEN G_LOCKROW_EXCEPTION THEN
               ROLLBACK TO Setup_Code_PVT;
               Raise_Error ('EAM_ROW_LOCKED',NULL,NULL);
	WHEN OTHERS THEN
		ROLLBACK TO Setup_Code_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Setup_Code;

PROCEDURE Setup_Combination
       (p_api_version      IN  NUMBER                                         ,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL         ,
        p_mode             IN  VARCHAR2                                       ,
        p_combination_rec  IN  EAM_FailureCodes_PUB.eam_combination_rec_type,
        x_return_status    OUT NOCOPY VARCHAR2                            ,
        x_msg_count        OUT NOCOPY NUMBER                              ,
        x_msg_data         OUT NOCOPY VARCHAR2                            ,
        x_combination_id   OUT NOCOPY NUMBER
       )
IS

l_api_name       CONSTANT VARCHAR2(30) := 'Setup_Combination';
l_api_version    CONSTANT NUMBER       := 1.0;

l_set_id                 NUMBER;
l_combination_id         NUMBER;
l_failure_exists         NUMBER;
l_cause_exists           NUMBER;
l_resolution_exists      NUMBER;
failure_rec              EAM_FailureCodes_PUB.eam_failurecode_rec_type;
cause_rec                EAM_FailureCodes_PUB.eam_failurecode_rec_type;
resolution_rec           EAM_FailureCodes_PUB.eam_failurecode_rec_type;
l_failure_code_status    VARCHAR2(1);
l_cause_code_status      VARCHAR2(1);
l_resolution_code_status VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(4000);
l_created_by             NUMBER;
l_creation_date          DATE;
l_last_update_date       DATE;
l_last_updated_by        NUMBER;
l_last_update_login      NUMBER;

CURSOR lock_combination IS
SELECT effective_end_date
  FROM eam_failure_combinations
 WHERE combination_id = l_combination_id
   FOR UPDATE NOWAIT;

BEGIN
    -- API savepoint
    SAVEPOINT Setup_Combination_PVT;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Combination Info passed
    Validate_Combination (p_mode, p_validation_level, p_combination_rec,
                          l_set_id,l_failure_exists, l_cause_exists,
                          l_resolution_exists, l_combination_id);
    IF (p_combination_rec.last_update_date is null) THEN
          l_created_by             := fnd_global.user_id;
          l_creation_date          := SYSDATE;
          l_last_update_date       := SYSDATE;
          l_last_updated_by        := fnd_global.user_id;
          l_last_update_login      := NULL;
    ELSE
          l_created_by             := p_combination_rec.created_by;
          l_creation_date          := p_combination_rec.creation_date;
          l_last_update_date       := p_combination_rec.last_update_date;
          l_last_updated_by        := p_combination_rec.last_updated_by;
          l_last_update_login      := p_combination_rec.last_update_login;
    END IF;

    IF (p_mode = 'C') THEN

        l_failure_code_status := FND_API.G_RET_STS_SUCCESS;
        l_cause_code_status := FND_API.G_RET_STS_SUCCESS;
        l_resolution_code_status := FND_API.G_RET_STS_SUCCESS;

	/** Commented since dynamic code creation is not allowed ** Bug#5070342
        IF (l_failure_exists = 0) THEN
           -- create failure code
           failure_rec.code_type  := EAM_FailureCodes_PUB.G_FAILURE_CODE;
           failure_rec.code       := p_combination_rec.failure_code;
           failure_rec.description:= p_combination_rec.failure_description;
           Setup_Code (p_api_version => 1.0,
                       p_init_msg_list => p_init_msg_list,
                       p_commit => FND_API.G_FALSE,
                       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                       p_mode => 'C',
                       p_failurecode_rec  => failure_rec,
                       x_return_status => l_failure_code_status,
                       x_msg_count => l_msg_count,
                       x_msg_data  => l_msg_data);
        END IF;

        l_cause_code_status := FND_API.G_RET_STS_SUCCESS;
        IF (l_cause_exists = 0) THEN
           -- create cause code
           cause_rec.code_type  := EAM_FailureCodes_PUB.G_CAUSE_CODE;
           cause_rec.code       := p_combination_rec.cause_code;
           cause_rec.description:= p_combination_rec.cause_description;
           Setup_Code (p_api_version => 1.0,
                       p_init_msg_list => p_init_msg_list,
                       p_commit => FND_API.G_FALSE,
                       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                       p_mode => 'C',
                       p_failurecode_rec  => cause_rec,
                       x_return_status => l_cause_code_status,
                       x_msg_count => l_msg_count,
                       x_msg_data  => l_msg_data);
        END IF;

        l_resolution_code_status := FND_API.G_RET_STS_SUCCESS;
        IF (l_resolution_exists = 0) THEN
           -- create resolution code
           resolution_rec.code_type  := EAM_FailureCodes_PUB.G_RESOLUTION_CODE;
           resolution_rec.code       := p_combination_rec.resolution_code;
           resolution_rec.description:= p_combination_rec.resolution_description;
           Setup_Code (p_api_version => 1.0,
                       p_init_msg_list => p_init_msg_list,
                       p_commit => FND_API.G_FALSE,
                       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                       p_mode => 'C',
                       p_failurecode_rec  => resolution_rec,
                       x_return_status => l_resolution_code_status,
                       x_msg_count => l_msg_count,
                       x_msg_data  => l_msg_data);
        END IF;
	**/

        IF (l_failure_code_status = FND_API.G_RET_STS_SUCCESS AND
            l_cause_code_status = FND_API.G_RET_STS_SUCCESS AND
            l_resolution_code_status = FND_API.G_RET_STS_SUCCESS) THEN

	    -- Insert into eam failure combinations
	     INSERT INTO eam_failure_combinations
                    (combination_id       ,
                     set_id               ,
                     failure_code         ,
                     cause_code           ,
                     resolution_code      ,
                     effective_end_date   ,
	             created_by           ,
	             creation_date        ,
	             last_update_date     ,
	             last_updated_by      ,
	             last_update_login)
	      VALUES (eam_failure_combinations_s.nextval          ,
	              l_set_id                            ,
	              p_combination_rec.failure_code      ,
	              p_combination_rec.cause_code        ,
	              p_combination_rec.resolution_code   ,
	              p_combination_rec.effective_end_date,
                      l_created_by        ,
                      l_creation_date     ,
                      l_last_update_date  ,
                      l_last_updated_by   ,
                      l_last_update_login)
             RETURNING combination_id INTO l_combination_id;

        END IF;

    ELSIF (p_mode = 'U') THEN
        -- update eam failure combinations
        BEGIN
           OPEN lock_combination;

           UPDATE eam_failure_combinations
              SET effective_end_date =
                             decode(p_combination_rec.effective_end_date,
                             NULL, effective_end_date,
                             FND_API.G_MISS_DATE, NULL,
                             p_combination_rec.effective_end_date),
                  last_update_date = l_last_update_date,
                  last_updated_by = l_last_updated_by,
                  last_update_login = l_last_update_login
            WHERE combination_id = l_combination_id;

           CLOSE lock_combination;
        EXCEPTION
             WHEN G_LOCKROW_EXCEPTION THEN
                  Raise_Error ('EAM_ROW_LOCKED',NULL,NULL);
        END;
   ELSIF (p_mode = 'D') THEN
      -- delete from eam failure combinations
      DELETE FROM eam_failure_combinations
       WHERE combination_id = l_combination_id;
   END IF;

   x_combination_id := l_combination_id;
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
   END IF;

   -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Setup_Combination_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count     	,
                 p_data  => x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Setup_Combination_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
                 p_data  => x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Setup_Combination_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Setup_Combination;

PROCEDURE Copy_FailureSet
         (p_api_version        IN  NUMBER                                     ,
          p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_commit             IN  VARCHAR2 := FND_API.G_FALSE                ,
          p_validation_level IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL         ,
          p_source_set_id      IN NUMBER                                      ,
          p_destination_set_id IN NUMBER                                      ,
          x_return_status      OUT NOCOPY VARCHAR2                            ,
          x_msg_count          OUT NOCOPY NUMBER                              ,
          x_msg_data           OUT NOCOPY VARCHAR2
          )
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Copy_FailureSet';
l_api_version   CONSTANT NUMBER       := 1.0;

BEGIN
    -- API savepoint
    SAVEPOINT Copy_FailureSet_PVT;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	       	G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	 FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Copy active combinations from source set to destination set
    INSERT INTO eam_failure_combinations
                    (combination_id       ,
                     set_id               ,
                     failure_code         ,
                     cause_code           ,
                     resolution_code      ,
                     effective_end_date   ,
	             created_by           ,
	             creation_date        ,
	             last_update_date     ,
	             last_updated_by      ,
	             last_update_login)
	      SELECT eam_failure_combinations_s.nextval,
	             p_destination_set_id  ,
	             efc.failure_code      ,
	             efc.cause_code        ,
	             efc.resolution_code   ,
	             efc.effective_end_date,
                     fnd_global.user_id,
                     SYSDATE,
                     SYSDATE,
                     fnd_global.user_id,
                     NULL
                FROM eam_failure_combinations efc
               WHERE set_id = p_source_set_id
                 AND effective_end_date IS NULL
                 AND NOT EXISTS
                     (SELECT 1
                        FROM eam_failure_combinations efc2
                       WHERE efc2.set_id = p_destination_set_id
                         AND efc2.failure_code = efc.failure_code
                         AND efc2.cause_code = efc.cause_code
                         AND efc2.resolution_code = efc2.resolution_code);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
   END IF;

   -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Copy_FailureSet_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count     	,
                 p_data  => x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Copy_FailureSet_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
                 p_data  => x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Copy_FailureSet_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Copy_FailureSet;

PROCEDURE Setup_Code_JSP
         (p_mode                 IN VARCHAR2,
          p_code_type            IN NUMBER  ,
          p_code                 IN VARCHAR2,
          p_description          IN VARCHAR2,
          p_effective_end_date   IN DATE    ,
          p_stored_last_upd_date IN DATE    ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2
         ) IS
l_failurecode_rec  EAM_FailureCodes_PUB.eam_failurecode_rec_type;
BEGIN
	l_failurecode_rec.code_type 		:= p_code_type;
	l_failurecode_rec.code 			:= p_code;
	l_failurecode_rec.stored_last_upd_date 	:= p_stored_last_upd_date;


        IF (p_mode = 'U' AND p_effective_end_date IS NULL) THEN
           l_failurecode_rec.effective_end_date := FND_API.G_MISS_DATE;
        ELSE
	   l_failurecode_rec.effective_end_date := p_effective_end_date;
        END IF;

        IF (p_mode = 'U' AND p_description IS NULL) THEN
           l_failurecode_rec.description := FND_API.G_MISS_CHAR;
        ELSE
	   l_failurecode_rec.description:= p_description;
        END IF;

        Setup_Code
                (p_api_version      => 1.0,
                 p_init_msg_list    => FND_API.G_TRUE,
                 p_commit           => FND_API.G_FALSE,
                 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                 p_mode             => p_mode,
                 p_failurecode_rec  => l_failurecode_rec,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data
                );
END Setup_Code_JSP;

PROCEDURE Setup_Combination_JSP
         (p_mode             	   IN VARCHAR2  ,
          p_set_id                 IN NUMBER    ,
	  p_set_name               IN VARCHAR2  ,
	  p_failure_code           IN VARCHAR2  ,
	  p_failure_description    IN VARCHAR2  ,
	  p_cause_code             IN VARCHAR2  ,
	  p_cause_description      IN VARCHAR2  ,
	  p_resolution_code        IN VARCHAR2  ,
	  p_resolution_description IN VARCHAR2  ,
	  p_effective_end_date     IN DATE      ,
	  p_combination_id         IN NUMBER    ,
	  p_stored_last_upd_date   IN DATE 	,
          p_created_by             IN NUMBER    ,
	  p_creation_date          IN DATE      ,
	  p_last_update_date       IN DATE      ,
	  p_last_updated_by        IN NUMBER    ,
	  p_last_update_login      IN NUMBER    ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2,
          x_combination_id   OUT NOCOPY NUMBER
          ) IS
l_combination_rec  EAM_FailureCodes_PUB.eam_combination_rec_type;
BEGIN
        l_combination_rec.set_id                 := p_set_id;
        l_combination_rec.set_name               := p_set_name;
        l_combination_rec.failure_code           := p_failure_code;
        l_combination_rec.failure_description    := p_failure_description;
        l_combination_rec.cause_code             := p_cause_code;
        l_combination_rec.cause_description      := p_cause_description;
        l_combination_rec.resolution_code        := p_resolution_code;
        l_combination_rec.resolution_description := p_resolution_description;
        l_combination_rec.combination_id         := p_combination_id;
        l_combination_rec.stored_last_upd_date   := p_stored_last_upd_date;
        l_combination_rec.created_by             := p_created_by;
        l_combination_rec.creation_date          := p_creation_date;
        l_combination_rec.last_update_date       := p_last_update_date;
        l_combination_rec.last_updated_by        := p_last_updated_by;
        l_combination_rec.last_update_login      := p_last_update_login;

        IF (p_mode = 'U' AND p_effective_end_date IS NULL) THEN
           l_combination_rec.effective_end_date := FND_API.G_MISS_DATE;
        ELSE
           l_combination_rec.effective_end_date := p_effective_end_date;
        END IF;

        Setup_Combination
       (p_api_version      => 1.0                       ,
        p_init_msg_list    => FND_API.G_TRUE            ,
        p_commit           => FND_API.G_FALSE           ,
        p_validation_level => FND_API.G_VALID_LEVEL_FULL,
        p_mode             => p_mode                    ,
        p_combination_rec  => l_combination_rec         ,
        x_return_status    => x_return_status           ,
        x_msg_count        => x_msg_count               ,
        x_msg_data         => x_msg_data                ,
        x_combination_id   => x_combination_id
       );
END Setup_Combination_JSP;

PROCEDURE Lock_Code_JSP
         (p_code_type         IN NUMBER  ,
          p_code              IN VARCHAR2,
          p_last_update_date  IN DATE    ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2
         ) IS
CURSOR lock_fc IS
SELECT description, effective_end_date, last_update_date
  FROM eam_failure_codes
 WHERE failure_code = p_code
   FOR UPDATE NOWAIT;

CURSOR lock_cc IS
SELECT description, effective_end_date, last_update_date
  FROM eam_cause_codes
 WHERE cause_code = p_code
   FOR UPDATE NOWAIT;

CURSOR lock_rc IS
SELECT description, effective_end_date, last_update_date
  FROM eam_resolution_codes
 WHERE resolution_code = p_code
   FOR UPDATE NOWAIT;

l_description           VARCHAR2(200);
l_end_date              DATE;
l_last_update_date      DATE;
l_rowcount              NUMBER;

BEGIN
        FND_MSG_PUB.initialize;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        BEGIN
         IF (p_code_type = EAM_FailureCodes_PUB.G_FAILURE_CODE) THEN
             OPEN lock_fc;
             FETCH lock_fc
              INTO l_description, l_end_date, l_last_update_date;
              l_rowcount := lock_fc%ROWCOUNT;
              CLOSE lock_fc;
         ELSIF (p_code_type = EAM_FailureCodes_PUB.G_CAUSE_CODE) THEN
             OPEN lock_cc;
             FETCH lock_cc
              INTO l_description, l_end_date, l_last_update_date;
              l_rowcount := lock_cc%ROWCOUNT;
              CLOSE lock_cc;
         ELSIF (p_code_type = EAM_FailureCodes_PUB.G_RESOLUTION_CODE) THEN
             OPEN lock_rc;
             FETCH lock_rc
              INTO l_description, l_end_date, l_last_update_date;
              l_rowcount := lock_rc%ROWCOUNT;
              CLOSE lock_rc;
         END IF;
         IF (p_last_update_date <> l_last_update_date) THEN
                       FND_MESSAGE.SET_NAME ('FND', 'FND_RECORD_CHANGED_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (l_rowcount = 0) THEN
                        FND_MESSAGE.SET_NAME ('FND', 'FND_RECORD_DELETED_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
         END IF;
	EXCEPTION
	  WHEN G_LOCKROW_EXCEPTION THEN
			FND_MESSAGE.SET_NAME ('FND', 'FND_LOCK_RECORD_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
	END;
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
        WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
                      'Lock_Code_JSP'
	    	      );
		END IF;
END Lock_Code_JSP;

PROCEDURE Lock_Combination_JSP
         (p_combination_id   IN NUMBER    ,
	  p_last_update_date IN DATE 	 ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2
          ) IS
CURSOR lock_combination IS
SELECT effective_end_date,last_update_date
  FROM eam_failure_combinations
 WHERE combination_id = p_combination_id
   FOR UPDATE NOWAIT;

l_end_date              DATE;
l_last_update_date      DATE;
l_rowcount              NUMBER;

BEGIN
        FND_MSG_PUB.initialize;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        BEGIN
                OPEN lock_combination;
                FETCH lock_combination
                INTO l_end_date, l_last_update_date;
                l_rowcount := lock_combination%ROWCOUNT;
                CLOSE lock_combination;
                IF (p_last_update_date <> l_last_update_date) THEN
                        FND_MESSAGE.SET_NAME ('FND', 'FND_RECORD_CHANGED_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF (l_rowcount = 0) THEN
                        FND_MESSAGE.SET_NAME ('FND', 'FND_RECORD_DELETED_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
	EXCEPTION
	        WHEN G_LOCKROW_EXCEPTION THEN
			FND_MESSAGE.SET_NAME ('FND', 'FND_LOCK_RECORD_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
	END;
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
        WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
                      'Lock_Code_JSP'
	    	      );
		END IF;
END Lock_Combination_JSP;

END EAM_FailureCodes_PVT;

/
