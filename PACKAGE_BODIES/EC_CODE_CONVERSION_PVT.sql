--------------------------------------------------------
--  DDL for Package Body EC_CODE_CONVERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_CODE_CONVERSION_PVT" AS
-- $Header: ECVXREFB.pls 120.2.12000000.2 2007/02/09 17:32:02 cpeixoto ship $

debug_mode_on_int	BOOLEAN := FALSE;


PROCEDURE Convert_from_ext_to_int
   (p_api_version_number  IN    NUMBER,
    p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE,
    p_simulate            IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN    VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT NOCOPY  VARCHAR2,
    p_msg_count           OUT NOCOPY  NUMBER,
    p_msg_data            OUT NOCOPY  VARCHAR2,
    p_Category            IN    VARCHAR2,
    p_Key1                IN    VARCHAR2 := NULL,
    p_Key2                IN    VARCHAR2 := NULL,
    p_Key3                IN    VARCHAR2 := NULL,
    p_Key4                IN    VARCHAR2 := NULL,
    p_Key5                IN    VARCHAR2 := NULL,
    p_Ext_val1            IN    VARCHAR2,
    p_Ext_val2            IN    VARCHAR2 := NULL,
    p_Ext_val3            IN    VARCHAR2 := NULL,
    p_Ext_val4            IN    VARCHAR2 := NULL,
    p_Ext_val5            IN    VARCHAR2 := NULL,
    p_Int_val             OUT NOCOPY  VARCHAR2) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'Convert_from_ext_to_int';
    l_api_version_number  CONSTANT NUMBER       := 1.0;

/* bug 5865153
    l_Int_val		varchar2(80) := NULL; */

    l_Int_val           ece_xref_data.xref_int_value%TYPE := NULL;


CURSOR match_5 IS
	SELECT  XREF_INT_VALUE
	FROM	ECE_XREF_DATA
	WHERE	XREF_KEY1 IS NOT NULL AND
                XREF_KEY2 IS NOT NULL AND
		XREF_KEY3 IS NOT NULL AND
		XREF_KEY4 IS NOT NULL AND
		XREF_KEY5 IS NOT NULL AND
		XREF_KEY1 = p_Key1 AND
		XREF_KEY2 = p_Key2 AND
		XREF_KEY3 = p_Key3 AND
		XREF_KEY4 = p_Key4 AND
		XREF_KEY5 = p_Key5 AND
		XREF_CATEGORY_CODE = p_Category AND
		XREF_EXT_VALUE1    = p_Ext_val1 AND
		(DIRECTION = 'IN' or DIRECTION = 'BOTH') AND
		NVL(XREF_EXT_VALUE2,FND_API.G_MISS_CHAR) = NVL(p_Ext_val2, FND_API.G_MISS_CHAR) AND
		NVL(XREF_EXT_VALUE3,FND_API.G_MISS_CHAR) = NVL(p_Ext_val3, FND_API.G_MISS_CHAR) AND
		NVL(XREF_EXT_VALUE4,FND_API.G_MISS_CHAR) = NVL(p_Ext_val4, FND_API.G_MISS_CHAR) AND
		NVL(XREF_EXT_VALUE5,FND_API.G_MISS_CHAR) = NVL(p_Ext_val5, FND_API.G_MISS_CHAR);

CURSOR match_4 IS
	SELECT	XREF_INT_VALUE
	FROM 	ECE_XREF_DATA
	WHERE	XREF_KEY1 IS NOT NULL AND
                XREF_KEY2 IS NOT NULL AND
                XREF_KEY3 IS NOT NULL AND
                XREF_KEY4 IS NOT NULL AND
                XREF_KEY5 IS NULL AND
                XREF_KEY1 = p_Key1 AND
                XREF_KEY2 = p_Key2 AND
                XREF_KEY3 = p_Key3 AND
                XREF_KEY4 = p_Key4 AND
                XREF_CATEGORY_CODE = p_Category AND
                XREF_EXT_VALUE1    = p_Ext_val1 AND
		(DIRECTION = 'IN' or DIRECTION = 'BOTH') AND
                NVL(XREF_EXT_VALUE2,FND_API.G_MISS_CHAR) = NVL(p_Ext_val2, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE3,FND_API.G_MISS_CHAR) = NVL(p_Ext_val3, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE4,FND_API.G_MISS_CHAR) = NVL(p_Ext_val4, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE5,FND_API.G_MISS_CHAR) = NVL(p_Ext_val5, FND_API.G_MISS_CHAR);

CURSOR match_3 IS
	SELECT	XREF_INT_VALUE
	FROM	ECE_XREF_DATA
	WHERE	XREF_KEY1 IS NOT NULL AND
                XREF_KEY2 IS NOT NULL AND
                XREF_KEY3 IS NOT NULL AND
                XREF_KEY4 IS NULL AND
                XREF_KEY5 IS NULL AND
                XREF_KEY1 = p_Key1 AND
                XREF_KEY2 = p_Key2 AND
                XREF_KEY3 = p_Key3 AND
                XREF_CATEGORY_CODE = p_Category AND
                XREF_EXT_VALUE1    = p_Ext_val1 AND
		(DIRECTION = 'IN' or DIRECTION = 'BOTH') AND
                NVL(XREF_EXT_VALUE2,FND_API.G_MISS_CHAR) = NVL(p_Ext_val2, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE3,FND_API.G_MISS_CHAR) = NVL(p_Ext_val3, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE4,FND_API.G_MISS_CHAR) = NVL(p_Ext_val4, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE5,FND_API.G_MISS_CHAR) = NVL(p_Ext_val5, FND_API.G_MISS_CHAR);

CURSOR match_2 IS
	SELECT	XREF_INT_VALUE
	FROM	ECE_XREF_DATA
	WHERE	XREF_KEY1 IS NOT NULL AND
                XREF_KEY2 IS NOT NULL AND
                XREF_KEY3 IS NULL AND
                XREF_KEY4 IS NULL AND
                XREF_KEY5 IS NULL AND
                XREF_KEY1 = p_Key1 AND
                XREF_KEY2 = p_Key2 AND
                XREF_CATEGORY_CODE = p_Category AND
                XREF_EXT_VALUE1    = p_Ext_val1 AND
		(DIRECTION = 'IN' or DIRECTION = 'BOTH') AND
                NVL(XREF_EXT_VALUE2,FND_API.G_MISS_CHAR) = NVL(p_Ext_val2, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE3,FND_API.G_MISS_CHAR) = NVL(p_Ext_val3, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE4,FND_API.G_MISS_CHAR) = NVL(p_Ext_val4, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE5,FND_API.G_MISS_CHAR) = NVL(p_Ext_val5, FND_API.G_MISS_CHAR);

CURSOR match_1 IS
	SELECT	XREF_INT_VALUE
	FROM	ECE_XREF_DATA
	WHERE	XREF_KEY1 IS NOT NULL AND
                XREF_KEY2 IS NULL AND
                XREF_KEY3 IS NULL AND
                XREF_KEY4 IS NULL AND
                XREF_KEY5 IS NULL AND
                XREF_KEY1 = p_Key1 AND
                XREF_CATEGORY_CODE = p_Category AND
                XREF_EXT_VALUE1    = p_Ext_val1 AND
		(DIRECTION = 'IN' or DIRECTION = 'BOTH') AND
                NVL(XREF_EXT_VALUE2,FND_API.G_MISS_CHAR) = NVL(p_Ext_val2, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE3,FND_API.G_MISS_CHAR) = NVL(p_Ext_val3, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE4,FND_API.G_MISS_CHAR) = NVL(p_Ext_val4, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE5,FND_API.G_MISS_CHAR) = NVL(p_Ext_val5, FND_API.G_MISS_CHAR);

CURSOR match_global IS
	SELECT	XREF_INT_VALUE
	FROM	ECE_XREF_DATA
	WHERE	XREF_KEY1 IS NULL AND
                XREF_KEY2 IS NULL AND
                XREF_KEY3 IS NULL AND
                XREF_KEY4 IS NULL AND
                XREF_KEY5 IS NULL AND
                XREF_CATEGORY_CODE = p_Category AND
                XREF_EXT_VALUE1    = p_Ext_val1 AND
		(DIRECTION = 'IN' or DIRECTION = 'BOTH') AND
                NVL(XREF_EXT_VALUE2,FND_API.G_MISS_CHAR) = NVL(p_Ext_val2, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE3,FND_API.G_MISS_CHAR) = NVL(p_Ext_val3, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE4,FND_API.G_MISS_CHAR) = NVL(p_Ext_val4, FND_API.G_MISS_CHAR) AND
                NVL(XREF_EXT_VALUE5,FND_API.G_MISS_CHAR) = NVL(p_Ext_val5, FND_API.G_MISS_CHAR);

BEGIN
  if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PUSH('EC_Code_Conversion_PVT.Convert_from_ext_to_int');
   EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_commit: ',p_commit);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   EC_DEBUG.PL(3, 'p_Category: ',p_Category);
   EC_DEBUG.PL(3, 'p_Key1: ',p_Key1);
   EC_DEBUG.PL(3, 'p_Key2: ',p_Key2);
   EC_DEBUG.PL(3, 'p_Key3: ',p_Key3);
   EC_DEBUG.PL(3, 'p_Key4: ',p_Key4);
   EC_DEBUG.PL(3, 'p_Key5: ',p_Key5);
   EC_DEBUG.PL(3, 'p_Ext_val1: ',p_Ext_val1);
   EC_DEBUG.PL(3, 'p_Ext_val2: ',p_Ext_val2);
   EC_DEBUG.PL(3, 'p_Ext_val3: ',p_Ext_val3);
   EC_DEBUG.PL(3, 'p_Ext_val4: ',p_Ext_val4);
   EC_DEBUG.PL(3, 'p_Ext_val5: ',p_Ext_val5);
   end if;
      -- Standard Start of API savepoint
      --      SAVEPOINT Convert_from_ext_to_int_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
       (l_api_version_number,
        p_api_version_number,
        l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      -- *******************************************************
      -- first validate the input key1-5
      --  The input has to be one of the following
      --  1. key1, key2, key3, key4, key5 all not null
      --  2. key1, key2, key3, key4   all not null
      --  3. key1, key2, key3     all not null
      --  4. key1, key2     all not null
      --  5. key1       all not null
      --  6. All null
      -- *******************************************************
      IF (((p_Key1 IS NOT NULL) AND (p_Key2 IS NOT NULL) AND (p_Key3 IS NOT NULL) AND
           (p_Key4 IS NOT NULL) AND (p_Key5 IS NOT NULL))
       OR ((p_Key1 IS NOT NULL) AND (p_Key2 IS NOT NULL) AND (p_Key3 IS NOT NULL) AND
           (p_Key4 IS NOT NULL) AND (p_Key5 IS NULL))
       OR ((p_Key1 IS NOT NULL) AND (p_Key2 IS NOT NULL) AND (p_Key3 IS NOT NULL) AND
           (p_Key4 IS NULL) AND (p_Key5 IS NULL))
       OR ((p_Key1 IS NOT NULL) AND (p_Key2 IS NOT NULL) AND (p_Key3 IS NULL) AND
           (p_Key4 IS NULL) AND (p_Key5 IS NULL))
       OR ((p_Key1 IS NOT NULL) AND (p_Key2 IS NULL) AND (p_Key3 IS NULL) AND
           (p_Key4 IS  NULL) AND (p_Key5 IS NULL))) THEN

        -- *******************************************************
        -- Start with matching all five keys
        --  if no 5-key matches  ->  search to match 4 keys
        --  if no 4-key matches  ->  search to match 3 keys
        --  if no 3-key matches  ->  search to match 2 keys
        --  if no 2-key matches  ->  search to match 1 keys
        --  if no 1-key matches  ->  search for generic match
        -- *******************************************************

        -- *******************************************************
        -- All 5 keys are supplied
        -- *******************************************************
        IF (NOT((p_Key1 IS NULL) OR (p_Key2 IS NULL) OR (p_Key3 IS NULL) OR
           (p_Key4 IS NULL) OR (p_Key5 IS NULL))) THEN
          OPEN match_5;
          FETCH match_5 INTO l_Int_val;
          IF match_5%NOTFOUND THEN
            OPEN match_4;
            FETCH match_4 INTO l_Int_val;
            IF match_4%NOTFOUND THEN
              OPEN match_3;
              FETCH match_3 INTO l_Int_val;
              IF match_3%NOTFOUND THEN
                OPEN match_2;
                FETCH match_2 INTO l_Int_val;
                IF match_2%NOTFOUND THEN
                  OPEN match_1;
                  FETCH match_1 INTO l_Int_val;
                  IF match_1%NOTFOUND THEN
                    OPEN match_global;
                    FETCH match_global INTO l_Int_val;
                    CLOSE match_global;
                  END IF;
                  CLOSE match_1;
                END IF;
                CLOSE match_2;
              END IF;
              CLOSE match_3;
            END IF;
            CLOSE match_4;
      		END IF;
      		CLOSE match_5;

				-- *******************************************************
				-- Four (4) keys are supplied
				-- *******************************************************
        ELSIF (NOT((p_Key1 IS NULL) OR (p_Key2 IS NULL) OR
              (p_Key3 IS NULL) OR (p_Key4 IS NULL))) THEN
          OPEN match_4;
          FETCH match_4 INTO l_Int_val;
          IF match_4%NOTFOUND THEN
            OPEN match_3;
            FETCH match_3 INTO l_Int_val;
            IF match_3%NOTFOUND THEN
              OPEN match_2;
              FETCH match_2 INTO l_Int_val;
              IF match_2%NOTFOUND THEN
                OPEN match_1;
                FETCH match_1 INTO l_Int_val;
                IF match_1%NOTFOUND THEN
                  OPEN match_global;
                  FETCH match_global INTO l_Int_val;
                  CLOSE match_global;
                END IF;
                CLOSE match_1;
              END IF;
              CLOSE match_2;
            END IF;
            CLOSE match_3;
          END IF;
          CLOSE match_4;

				-- *******************************************************
				-- Three (3) keys are supplied
				-- *******************************************************
        ELSIF (NOT((p_Key1 IS NULL) OR (p_Key2 IS NULL) OR
              (p_Key3 IS NULL))) THEN
          OPEN match_3;
          FETCH match_3 INTO l_Int_val;
          IF match_3%NOTFOUND THEN
            OPEN match_2;
            FETCH match_2 INTO l_Int_val;
            IF match_2%NOTFOUND THEN
              OPEN match_1;
              FETCH match_1 INTO l_Int_val;
              IF match_1%NOTFOUND THEN
                OPEN match_global;
                FETCH match_global INTO l_Int_val;
                CLOSE match_global;
              END IF;
              CLOSE match_1;
            END IF;
            CLOSE match_2;
          END IF;
          CLOSE match_3;
          if EC_DEBUG.G_debug_level >= 3 then
          EC_DEBUG.PL(3, 'l_Int_val :', l_Int_val);
          end if;
        -- *******************************************************
        -- Two (2) keys are supplied
        -- *******************************************************
        ELSIF (NOT((p_Key1 IS NULL) OR (p_Key2 IS NULL))) THEN
          OPEN match_2;
          FETCH match_2 INTO l_Int_val;
          IF match_2%NOTFOUND THEN
            OPEN match_1;
            FETCH match_1 INTO l_Int_val;
            IF match_1%NOTFOUND THEN
              OPEN match_global;
              FETCH match_global INTO l_Int_val;
              CLOSE match_global;
            END IF;
            CLOSE match_1;
          END IF;
          CLOSE match_2;

				-- *******************************************************
				-- One (1) key is supplied
				-- *******************************************************
        ELSIF (p_Key1 IS NOT NULL) THEN
          OPEN match_1;
          FETCH match_1 INTO l_Int_val;
          IF match_1%NOTFOUND THEN
            OPEN match_global;
            FETCH match_global INTO l_Int_val;
            CLOSE match_global;
          END IF;
          CLOSE match_1;
        END IF;
      ELSE

        -- *******************************
        -- all keys (1-5) are NULLs
        -- *******************************
        OPEN match_global;
        FETCH match_global INTO l_Int_val;
        CLOSE match_global;
      END IF;

      -- *******************************************************
      -- Standard check of p_simulate and p_commit parameters
      -- *******************************************************
/*
      IF FND_API.To_Boolean(p_simulate) THEN
        ROLLBACK TO Convert_from_ext_to_int_PVT;
      ELSIF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;
*/
      if l_Int_val is null
      then
      /* p_return_status := EC_Code_Conversion_PVT.G_XREF_NOT_FOUND;
         fnd_message.set_name('EC','ECE_XREF_NOT_FOUND');
         fnd_message.set_token('DATA', p_Ext_val1);
         p_msg_data := fnd_message.get; */

         -- We change the behavior of the code conversion.
         -- If it can't find the value, then simply copy the external
         -- value1 to internal value instead of giving out an error message.
         p_Int_val := p_Ext_val1;
      else
         if EC_DEBUG.G_debug_level = 3 then
         EC_DEBUG.PL(3, 'l_Int_val :', l_Int_val);
         end if;
         p_Int_val := l_Int_val;

      end if;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				p_data  => p_msg_data);

 if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.POP('EC_Code_Conversion_PVT.Convert_from_ext_to_int');
 end if;
    EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
--				ROLLBACK TO Convert_from_ext_to_int_PVT;
	p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				 p_data => p_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--				ROLLBACK TO Convert_from_ext_to_int_PVT;
	p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				 p_data => p_msg_data);
WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
--				ROLLBACK TO Convert_from_ext_to_int_PVT;
	p_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		FND_MSG_PUB.Add_Exc_Msg(G_FILE_NAME, G_PKG_NAME, l_api_name);
        END IF;
	FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				 p_data	=> p_msg_data);
END Convert_from_ext_to_int;

  PROCEDURE Convert_from_int_to_ext
   (p_api_version_number  IN    NUMBER,
    p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
    p_simulate            IN    VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN    VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN    NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT NOCOPY  VARCHAR2,
    p_msg_count           OUT NOCOPY  NUMBER,
    p_msg_data            OUT NOCOPY  VARCHAR2,
    p_Category            IN    VARCHAR2,
    p_Key1                IN    VARCHAR2  := NULL,
    p_Key2                IN    VARCHAR2  := NULL,
    p_Key3                IN    VARCHAR2  := NULL,
    p_Key4                IN    VARCHAR2  := NULL,
    p_Key5                IN    VARCHAR2  := NULL,
    p_Int_val             IN    VARCHAR2,
    p_Ext_val1            OUT NOCOPY  VARCHAR2,
    p_Ext_val2            OUT NOCOPY  VARCHAR2,
    p_Ext_val3            OUT NOCOPY  VARCHAR2,
    p_Ext_val4            OUT NOCOPY  VARCHAR2,
    p_Ext_val5            OUT NOCOPY  VARCHAR2) IS

    l_api_name            CONSTANT  VARCHAR2(30)  := 'Convert_from_int_to_ext';
    l_api_version_number  CONSTANT  NUMBER        :=  1.0;

/* bug 5865153
    l_Ext_val1		varchar2(500) := NULL;
    l_Ext_val2		varchar2(500) := NULL;
    l_Ext_val3		varchar2(500) := NULL;
    l_Ext_val4		varchar2(500) := NULL;
    l_Ext_val5		varchar2(500) := NULL; */

    l_Ext_val1          ece_xref_data.xref_ext_value1%TYPE := NULL;
    l_Ext_val2          ece_xref_data.xref_ext_value2%TYPE := NULL;
    l_Ext_val3          ece_xref_data.xref_ext_value3%TYPE := NULL;
    l_Ext_val4          ece_xref_data.xref_ext_value4%TYPE := NULL;
    l_Ext_val5          ece_xref_data.xref_ext_value5%TYPE := NULL;


    CURSOR match_5 IS
      SELECT  XREF_EXT_VALUE1,
              XREF_EXT_VALUE2,
              XREF_EXT_VALUE3,
              XREF_EXT_VALUE4,
              XREF_EXT_VALUE5
      FROM    ECE_XREF_DATA
      WHERE   XREF_KEY1 IS NOT NULL AND
              XREF_KEY2 IS NOT NULL AND
              XREF_KEY3 IS NOT NULL AND
              XREF_KEY4 IS NOT NULL AND
              XREF_KEY5 IS NOT NULL AND
              XREF_KEY1 = p_Key1 AND
              XREF_KEY2 = p_Key2 AND
              XREF_KEY3 = p_Key3 AND
              XREF_KEY4 = p_Key4 AND
              XREF_KEY5 = p_Key5 AND
              XREF_INT_VALUE     = p_Int_val AND
              XREF_CATEGORY_CODE = p_Category AND
              (DIRECTION = 'OUT' or DIRECTION = 'BOTH');

    CURSOR match_4 IS
      SELECT  XREF_EXT_VALUE1,
              XREF_EXT_VALUE2,
              XREF_EXT_VALUE3,
              XREF_EXT_VALUE4,
              XREF_EXT_VALUE5
      FROM    ECE_XREF_DATA
      WHERE   XREF_KEY1 IS NOT NULL AND
              XREF_KEY2 IS NOT NULL AND
              XREF_KEY3 IS NOT NULL AND
              XREF_KEY4 IS NOT NULL AND
              XREF_KEY5 IS NULL AND
              XREF_KEY1 = p_Key1 AND
              XREF_KEY2 = p_Key2 AND
              XREF_KEY3 = p_Key3 AND
              XREF_KEY4 = p_Key4 AND
              XREF_INT_VALUE     = p_Int_val AND
              XREF_CATEGORY_CODE = p_Category AND
              (DIRECTION = 'OUT' or DIRECTION = 'BOTH');

    CURSOR match_3 IS
      SELECT  XREF_EXT_VALUE1,
              XREF_EXT_VALUE2,
              XREF_EXT_VALUE3,
              XREF_EXT_VALUE4,
              XREF_EXT_VALUE5
      FROM    ECE_XREF_DATA
      WHERE   XREF_KEY1 IS NOT NULL AND
              XREF_KEY2 IS NOT NULL AND
              XREF_KEY3 IS NOT NULL AND
              XREF_KEY4 IS NULL AND
              XREF_KEY5 IS NULL AND
              XREF_KEY1 = p_Key1 AND
              XREF_KEY2 = p_Key2 AND
              XREF_KEY3 = p_Key3 AND
              XREF_INT_VALUE     = p_Int_val AND
              XREF_CATEGORY_CODE = p_Category AND
              (DIRECTION = 'OUT' or DIRECTION = 'BOTH');

    CURSOR match_2 IS
      SELECT  XREF_EXT_VALUE1,
              XREF_EXT_VALUE2,
              XREF_EXT_VALUE3,
              XREF_EXT_VALUE4,
              XREF_EXT_VALUE5
      FROM    ECE_XREF_DATA
      WHERE   XREF_KEY1 IS NOT NULL AND
              XREF_KEY2 IS NOT NULL AND
              XREF_KEY3 IS NULL AND
              XREF_KEY4 IS NULL AND
              XREF_KEY5 IS NULL AND
              XREF_KEY1 = p_Key1 AND
              XREF_KEY2 = p_Key2 AND
              XREF_INT_VALUE = p_Int_val AND
              XREF_CATEGORY_CODE = p_Category AND
              (DIRECTION = 'OUT' or DIRECTION = 'BOTH');

    CURSOR match_1 IS
      SELECT  XREF_EXT_VALUE1,
              XREF_EXT_VALUE2,
              XREF_EXT_VALUE3,
              XREF_EXT_VALUE4,
              XREF_EXT_VALUE5
      FROM    ECE_XREF_DATA
      WHERE   XREF_KEY1 IS NOT NULL AND
              XREF_KEY2 IS NULL AND
              XREF_KEY3 IS NULL AND
              XREF_KEY4 IS NULL AND
              XREF_KEY5 IS NULL AND
              XREF_KEY1 = p_Key1 AND
              XREF_INT_VALUE     = p_Int_val AND
              XREF_CATEGORY_CODE = p_Category AND
              (DIRECTION = 'OUT' or DIRECTION = 'BOTH');

    CURSOR match_global IS
      SELECT  XREF_EXT_VALUE1,
              XREF_EXT_VALUE2,
              XREF_EXT_VALUE3,
              XREF_EXT_VALUE4,
              XREF_EXT_VALUE5
      FROM    ECE_XREF_DATA
      WHERE   XREF_KEY1 IS NULL AND
              XREF_KEY2 IS NULL AND
              XREF_KEY3 IS NULL AND
              XREF_KEY4 IS NULL AND
              XREF_KEY5 IS NULL AND
              XREF_INT_VALUE     = p_Int_val AND
              XREF_CATEGORY_CODE = p_Category AND
              (DIRECTION = 'OUT' or DIRECTION = 'BOTH');

    BEGIN

 if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PUSH('EC_Code_Conversion_PVT.Convert_from_int_to_ext');
   EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_commit: ',p_commit);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   EC_DEBUG.PL(3, 'p_Category: ',p_Category);
   EC_DEBUG.PL(3, 'p_Key1: ',p_Key1);
   EC_DEBUG.PL(3, 'p_Key2: ',p_Key2);
   EC_DEBUG.PL(3, 'p_Key3: ',p_Key3);
   EC_DEBUG.PL(3, 'p_Key4: ',p_Key4);
   EC_DEBUG.PL(3, 'p_Key5: ',p_Key5);
   EC_DEBUG.PL(3, 'p_Int_val: ',p_Int_val);
   end if;
      -- Standard Start of API savepoint
--      SAVEPOINT Convert_from_int_to_ext_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
       (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      -- *******************************************************
      -- first validate the input key1-5
      --  The input has to be one of the following
      --  1. key1, key2, key3, key4, key5 all not null
      --  2. key1, key2, key3, key4   all not null
      --  3. key1, key2, key3     all not null
      --  4. key1, key2     all not null
      --  5. key1       all not null
      --   6. All null
      -- *******************************************************
      IF (((p_Key1 IS NOT NULL) AND (p_Key2 IS NOT NULL)  AND (p_Key3 IS NOT NULL) AND
           (p_Key4 IS NOT NULL) AND (p_Key5 IS NOT NULL)) OR ((p_Key1 IS NOT NULL) AND
           (p_Key2 IS NOT NULL) AND (p_Key3 IS NOT NULL)  AND (p_Key4 IS NOT NULL) AND
           (p_Key5 IS NULL))    OR ((p_Key1 IS NOT NULL)  AND (p_Key2 IS NOT NULL) AND
           (p_Key3 IS NOT NULL) AND (p_Key4 IS NULL)      AND (p_Key5 IS NULL))    OR
          ((p_Key1 IS NOT NULL) AND (p_Key2 IS NOT NULL)  AND (p_Key3 IS NULL)     AND
           (p_Key4 IS NULL)     AND (p_Key5 IS NULL))     OR ((p_Key1 IS NOT NULL) AND
           (p_Key2 IS NULL)     AND (p_Key3 IS NULL)      AND (p_Key4 IS NULL)     AND
           (p_Key5 IS NULL)))
      THEN
        -- *******************************************************
        -- Start with matching all five keys
        --  if no 5-key matches  ->  search to match 4 keys
        --  if no 4-key matches  ->  search to match 3 keys
        --  if no 3-key matches  ->  search to match 2 keys
        --  if no 2-key matches  ->  search to match 1 keys
        --  if no 1-key matches  ->  search for generic match
        -- *******************************************************

        -- *******************************************************
        -- All 5 keys are supplied
        -- *******************************************************
        IF (NOT((p_Key1 IS NULL) OR (p_Key2 IS NULL) OR (p_Key3 IS NULL) OR
           (p_Key4 IS NULL) OR (p_Key5 IS NULL))) THEN
          OPEN match_5;
          FETCH match_5 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                             l_Ext_val4,l_Ext_val5;
          IF match_5%NOTFOUND THEN
            OPEN match_4;
            FETCH match_4 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                               l_Ext_val4,l_Ext_val5;
            IF match_4%NOTFOUND THEN
              OPEN match_3;
              FETCH match_3 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                 l_Ext_val4,l_Ext_val5;
              IF match_3%NOTFOUND THEN
                OPEN match_2;
                FETCH match_2 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                   l_Ext_val4,l_Ext_val5;
                IF match_2%NOTFOUND THEN
                  OPEN match_1;
                  FETCH match_1 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                     l_Ext_val4,l_Ext_val5;
                  IF match_1%NOTFOUND THEN
                    OPEN match_global;
                    FETCH match_global INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                            l_Ext_val4,l_Ext_val5;
                    CLOSE match_global;
                  END IF;
                  CLOSE match_1;
                END IF;
                CLOSE match_2;
              END IF;
              CLOSE match_3;
            END IF;
            CLOSE match_4;
          END IF;
          CLOSE match_5;

        -- *******************************************************
        -- Four (4) keys are supplied
        -- *******************************************************
        ELSIF (NOT((p_Key1 IS NULL) OR (p_Key2 IS NULL) OR
                   (p_Key3 IS NULL) OR (p_Key4 IS NULL))) THEN
          OPEN match_4;
          FETCH match_4 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                             l_Ext_val4,l_Ext_val5;
          IF match_4%NOTFOUND THEN
            OPEN match_3;
            FETCH match_3 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                               l_Ext_val4,l_Ext_val5;
            IF match_3%NOTFOUND THEN
              OPEN match_2;
              FETCH match_2 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                 l_Ext_val4,l_Ext_val5;
              IF match_2%NOTFOUND THEN
                OPEN match_1;
                FETCH match_1 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                   l_Ext_val4,l_Ext_val5;
                IF match_1%NOTFOUND THEN
                  OPEN match_global;
                  FETCH match_global INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                          l_Ext_val4,l_Ext_val5;
                  CLOSE match_global;
                END IF;
                CLOSE match_1;
              END IF;
              CLOSE match_2;
            END IF;
            CLOSE match_3;
          END IF;
          CLOSE match_4;

        -- *******************************************************
        -- Three (3) keys are supplied
        -- *******************************************************
        ELSIF (NOT((p_Key1 IS NULL) OR (p_Key2 IS NULL) OR (p_Key3 IS NULL))) THEN
          OPEN match_3;
          FETCH match_3 INTO l_Ext_val1,l_Ext_val2,
                             l_Ext_val3,l_Ext_val4,l_Ext_val5;
          IF match_3%NOTFOUND THEN
            OPEN match_2;
            FETCH match_2 INTO l_Ext_val1,l_Ext_val2,
                               l_Ext_val3,l_Ext_val4,l_Ext_val5;
            IF match_2%NOTFOUND THEN
              OPEN match_1;
              FETCH match_1 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                 l_Ext_val4,l_Ext_val5;
              IF match_1%NOTFOUND THEN
                OPEN match_global;
                FETCH match_global INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                        l_Ext_val4,l_Ext_val5;
                CLOSE match_global;
              END IF;
              CLOSE match_1;
            END IF;
            CLOSE match_2;
          END IF;
          CLOSE match_3;

        -- *******************************************************
        -- Two (2) keys are supplied
        -- *******************************************************
        ELSIF (NOT((p_Key1 IS NULL) OR (p_Key2 IS NULL))) THEN
          OPEN match_2;
          FETCH match_2 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                             l_Ext_val4,l_Ext_val5;
          IF match_2%NOTFOUND THEN
            OPEN match_1;
            FETCH match_1 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                               l_Ext_val4,l_Ext_val5;
            IF match_1%NOTFOUND THEN
              OPEN match_global;
              FETCH match_global INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                      l_Ext_val4,l_Ext_val5;
              CLOSE match_global;
            END IF;
            CLOSE match_1;
          END IF;
          CLOSE match_2;

        -- *******************************************************
        -- One (1) key is supplied
        -- *******************************************************
        ELSIF (p_Key1 IS NOT NULL) THEN
          OPEN match_1;
          FETCH match_1 INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                             l_Ext_val4,l_Ext_val5;
          IF match_1%NOTFOUND THEN
            OPEN match_global;
            FETCH match_global INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                    l_Ext_val4,l_Ext_val5;
            CLOSE match_global;
          END IF;
          CLOSE match_1;
        END IF;

      ELSE

        -- *******************************
        -- all keys (1-5) are NULLs
        -- *******************************
        OPEN match_global;
        FETCH match_global INTO l_Ext_val1,l_Ext_val2,l_Ext_val3,
                                l_Ext_val4,l_Ext_val5;
        CLOSE match_global;
      END IF;

      if  l_Ext_val1 is null
      and l_Ext_val2 is null
      and l_Ext_val3 is null
      and l_Ext_val4 is null
      and l_Ext_val5 is null
      then
      /* p_return_status := EC_Code_Conversion_PVT.G_XREF_NOT_FOUND;
         fnd_message.set_name('EC','ECE_XREF_NOT_FOUND');
         fnd_message.set_token('DATA', p_Int_val);
         p_msg_data := fnd_message.get; */

         -- We change the behavior of the code conversion.
         -- If it can't find the value, then simply copy the internal
         -- value to external value1 instead of giving out an error message.
         p_Ext_val1 := p_Int_val;
      else
         p_Ext_val1 := l_Ext_val1;
         p_Ext_val2 := l_Ext_val2;
         p_Ext_val3 := l_Ext_val3;
         p_Ext_val4 := l_Ext_val4;
         p_Ext_val5 := l_Ext_val5;
         if EC_DEBUG.G_debug_level = 3 then
         EC_DEBUG.PL(3, 'l_Ext_val1: ',l_Ext_val1);
         EC_DEBUG.PL(3, 'l_Ext_val2: ',l_Ext_val2);
         EC_DEBUG.PL(3, 'l_Ext_val3: ',l_Ext_val3);
         EC_DEBUG.PL(3, 'l_Ext_val4: ',l_Ext_val4);
         EC_DEBUG.PL(3, 'l_Ext_val5: ',l_Ext_val5);
         end if;
      end if;

      -- *******************************************************
      -- Standard check of p_simulate and p_commit parameters
      -- *******************************************************
/*
      IF FND_API.To_Boolean(p_simulate) THEN
        ROLLBACK TO Convert_from_int_to_ext_PVT;
      ELSIF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;
*/
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,p_data => p_msg_data);

 if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.POP('EC_Code_Conversion_PVT.Convert_from_int_to_ext');
 end if;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
--        ROLLBACK TO Convert_from_int_to_ext_PVT;
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data => p_msg_data);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--        ROLLBACK TO Convert_from_int_to_ext_PVT;
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data => p_msg_data);
 WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
--        ROLLBACK TO Convert_from_int_to_ext_PVT;
        p_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_FILE_NAME, G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data => p_msg_data);

END Convert_from_int_to_ext;

PROCEDURE populate_plsql_tbl_with_extval
   (p_api_version_number  IN      NUMBER,
    p_init_msg_list       IN      VARCHAR2  := FND_API.G_FALSE,
    p_simulate            IN      VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN      VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT NOCOPY    VARCHAR2,
    p_msg_count           OUT NOCOPY    NUMBER,
    p_msg_data            OUT NOCOPY    VARCHAR2,
    p_key_tbl             IN      ece_flatfile_pvt.Interface_tbl_type,
    p_tbl                 IN OUT  NOCOPY ece_flatfile_pvt.Interface_tbl_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'populate_plsql_tbl_with_extval';
    l_api_version_number  CONSTANT NUMBER       :=  1.0;

    ckey1_used_flag       VARCHAR2(1);
    ckey2_used_flag       VARCHAR2(1);
    ckey3_used_flag       VARCHAR2(1);
    ckey4_used_flag       VARCHAR2(1);
    ckey5_used_flag       VARCHAR2(1);

    ckey1_used_table      VARCHAR2(80);
    ckey2_used_table      VARCHAR2(80);
    ckey3_used_table      VARCHAR2(80);
    ckey4_used_table      VARCHAR2(80);
    ckey5_used_table      VARCHAR2(80);

    ckey1_used_column     VARCHAR2(80);
    ckey2_used_column     VARCHAR2(80);
    ckey3_used_column     VARCHAR2(80);
    ckey4_used_column     VARCHAR2(80);
    ckey5_used_column     VARCHAR2(80);

    cxref_category_code   VARCHAR2(30);

    key1                  VARCHAR2(500);  -- 4011384
    key2                  VARCHAR2(500);
    key3                  VARCHAR2(500);
    key4                  VARCHAR2(500);
    key5                  VARCHAR2(500);

    ext1                  VARCHAR2(500);
    ext2                  VARCHAR2(500);
    ext3                  VARCHAR2(500);
    ext4                  VARCHAR2(500);
    ext5                  VARCHAR2(500);

    return_code           NUMBER;
    icount                NUMBER;
    l_return_status       VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    i                     INTEGER;
    j                     INTEGER;
    l_ext_pos		  NUMBER;
    b_xref_data_found     BOOLEAN;

	BEGIN

  if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PUSH('EC_Code_Conversion_PVT.populate_plsql_tbl_with_extval');
   EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_commit: ',p_commit);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   end if;
	-- Standard Start of API savepoint
	SAVEPOINT populate_plsql_tbl_PVT;

	-- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
       (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list) THEN
				FND_MSG_PUB.initialize;
      END IF;

	-- Initialize API return status to success
	p_return_status := FND_API.G_RET_STS_SUCCESS;

	-- *******************************************************
	-- work on each row in the p_tbl pl/sql
	-- table to fill in the ext1-5 value
	-- *******************************************************
	icount := p_tbl.COUNT;

      FOR i IN 1..icount LOOP
        IF (p_tbl(i).xref_category_id IS NOT NULL) THEN
	-- use this xref_id, go to ece_xref_category to find out all the
	-- enabled keys
	SELECT	  key1_used_flag, key2_used_flag, key3_used_flag,
                  key4_used_flag, key5_used_flag,
                  key1_used_table, key2_used_table, key3_used_table,
                  key4_used_table, key5_used_table,
                  key1_used_column, key2_used_column, key3_used_column,
                  key4_used_column, key5_used_column,
                  xref_category_code
	INTO	  ckey1_used_flag, ckey2_used_flag, ckey3_used_flag,
                  ckey4_used_flag, ckey5_used_flag,
                  ckey1_used_table, ckey2_used_table, ckey3_used_table,
                  ckey4_used_table, ckey5_used_table,
                  ckey1_used_column, ckey2_used_column, ckey3_used_column,
                  ckey4_used_column, ckey5_used_column,
                  cxref_category_code
	FROM	  ece_xref_categories
	WHERE	  ece_xref_categories.xref_category_id = p_tbl(i).xref_category_id;

          IF ckey1_used_flag = 'Y' AND
             p_tbl(i).xref_key1_source_column IS NOT NULL THEN
            FOR j IN 1..p_key_tbl.count LOOP
              IF p_tbl(i).xref_key1_source_column =
                 p_key_tbl(j).interface_column_name THEN
                key1 := p_key_tbl(j).value;
                if EC_DEBUG.G_debug_level >= 3 then
                EC_DEBUG.PL(3, 'key1 :', key1);
                end if;
		EXIT;
	      END IF;
	    END LOOP;
		-- we assume all the key can be found in the pl/sql table
	  END IF;

          IF ckey2_used_flag = 'Y' AND
             p_tbl(i).xref_key2_source_column IS NOT NULL THEN
            FOR j IN 1..p_key_tbl.count LOOP
              IF p_tbl(i).xref_key2_source_column =
                 p_key_tbl(j).interface_column_name THEN
                key2 := p_key_tbl(j).value;
                if EC_DEBUG.G_debug_level >= 3 then
                EC_DEBUG.PL(3, 'key2 :', key2);
                end if;
		EXIT;
	      END IF;
	    END LOOP;
	  END IF;

          IF ckey3_used_flag = 'Y' AND
             p_tbl(i).xref_key3_source_column IS NOT NULL THEN
            FOR j in 1..p_key_tbl.count LOOP
              IF p_tbl(i).xref_key3_source_column =
                 p_key_tbl(j).interface_column_name THEN
                key3 := p_key_tbl(j).value;
                if EC_DEBUG.G_debug_level >= 3 then
                EC_DEBUG.PL(3, 'key3 :', key3);
                end if;
		EXIT;
	      END IF;
	    END LOOP;
	  END IF;

          IF ckey4_used_flag = 'Y' AND
             p_tbl(i).xref_key4_source_column IS NOT NULL THEN
            FOR j IN 1..p_key_tbl.count LOOP
              IF p_tbl(i).xref_key4_source_column =
                 p_key_tbl(j).interface_column_name THEN
		key4 := p_key_tbl(j).value;
                if EC_DEBUG.G_debug_level >= 3 then
                EC_DEBUG.PL(3, 'key4 :', key4);
                end if;
		EXIT;
	      END IF;
	    END LOOP;
	END IF;

          IF ckey5_used_flag = 'Y' AND
             p_tbl(i).xref_key5_source_column IS NOT NULL THEN
            FOR j IN 1..p_key_tbl.count LOOP
              IF p_tbl(i).xref_key5_source_column =
                 p_key_tbl(j).interface_column_name THEN
		key5 := p_key_tbl(j).value;
                if EC_DEBUG.G_debug_level >= 3 then
                EC_DEBUG.PL(3, 'key5 :', key5);
                end if;
		EXIT;
              END IF;
	    END LOOP;
	END IF;

	-- Now we know the int_value, the actual value of the key1-5,
	-- so we just need to call int_2_ext APIs to get the
	-- the ext1-5 value
          EC_Code_Conversion_PVT.Convert_from_int_to_ext
           (p_api_version_number  => 1.0,
            p_return_status       => l_return_status,
            p_msg_count           => l_msg_count,
            p_msg_data            => l_msg_data,
            p_Category            => cxref_category_code,
            p_Key1                => key1,
            p_Key2                => key2,
            p_Key3                => key3,
            p_Key4                => key4,
            p_Key5                => key5,
            p_Int_val             => p_tbl(i).value,
            p_Ext_val1            => ext1,
            p_Ext_val2            => ext2,
            p_Ext_val3            => ext3,
            p_Ext_val4            => ext4,
            p_Ext_val5            => ext5);

            p_tbl(i).ext_val1 := ext1;
            p_tbl(i).ext_val2 := ext2;
            p_tbl(i).ext_val3 := ext3;
            p_tbl(i).ext_val4 := ext4;
            p_tbl(i).ext_val5 := ext5;

            key1 := NULL;
            key2 := NULL;
            key3 := NULL;
            key4 := NULL;
            key5 := NULL;

           -- ******************************
           -- Need to populate the value column
           -- of all the corresponding external
           -- values, e.g. UOM_CODE_EXT1
           -- ******************************

           IF ext1 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext1 :', ext1);
             end if;
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_tbl,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 1,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext1;
              END IF;
           END IF;

           IF ext2 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext2 :', ext2);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_tbl,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 2,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext2;
              END IF;
           END IF;

           IF ext3 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext3 :', ext3);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_tbl,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 3,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext3;
              END IF;
           END IF;

           IF ext4 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext4 :', ext4);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_tbl,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 4,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext4;
              END IF;
           END IF;

           IF ext5 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext5 :', ext5);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_tbl,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 5,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext5;
              END IF;
           END IF;

        -- This is to copy the internal value to external value if
        -- there is no category code assigned to the interface column and
        -- the external value1 is null.

        ELSIF (p_tbl(i).conversion_seq = 0) THEN
           b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
          (p_gateway_tbl       => p_tbl,
           p_conversion_group  => p_tbl(i).conversion_group_id,
           p_sequence_num      => 1,
           p_Pos               => l_ext_pos);

           IF b_xref_data_found THEN
              p_tbl(l_ext_pos).value := p_tbl(i).value;
              p_tbl(i).ext_val1 := p_tbl(i).value;
           END IF;

        END IF;
      END LOOP;

	-- *******************************************************
	-- Standard check of p_simulate and p_commit parameters
	-- *******************************************************
      IF FND_API.To_Boolean(p_simulate) THEN
				ROLLBACK TO populate_plsql_tbl_PVT;
      ELSIF FND_API.To_Boolean(p_commit) THEN
				COMMIT WORK;
	END IF;

      -- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);

      if l_return_status = EC_Code_Conversion_PVT.G_XREF_NOT_FOUND
      then
         p_return_status := EC_Code_Conversion_PVT.G_XREF_NOT_FOUND;
      end if;

 if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.POP('EC_Code_Conversion_PVT.populate_plsql_tbl_with_extval');
 end if;
EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO populate_plsql_tbl_PVT;
			p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
				ROLLBACK TO populate_plsql_tbl_PVT;
				p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);
      WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ROLLBACK TO populate_plsql_tbl_PVT;
	p_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
					FND_MSG_PUB.Add_Exc_Msg(G_FILE_NAME, G_PKG_NAME, l_api_name);
	END IF;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);

END populate_plsql_tbl_with_extval;

PROCEDURE populate_plsql_tbl_with_extval
   (p_api_version_number  IN      	NUMBER,
    p_init_msg_list       IN      	VARCHAR2  := FND_API.G_FALSE,
    p_simulate            IN      	VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN      	VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN      	NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT  NOCOPY  	VARCHAR2,
    p_msg_count           OUT  NOCOPY  	NUMBER,
    p_msg_data            OUT  NOCOPY   VARCHAR2,
    p_tbl            	  IN OUT NOCOPY ec_utils.mapping_tbl,
    p_level               IN 		NUMBER) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'populate_plsql_tbl_with_extval';
    l_api_version_number  CONSTANT NUMBER       :=  1.0;

    ckey1_used_flag       VARCHAR2(1);
    ckey2_used_flag       VARCHAR2(1);
    ckey3_used_flag       VARCHAR2(1);
    ckey4_used_flag       VARCHAR2(1);
    ckey5_used_flag       VARCHAR2(1);

    ckey1_used_table      VARCHAR2(80);
    ckey2_used_table      VARCHAR2(80);
    ckey3_used_table      VARCHAR2(80);
    ckey4_used_table      VARCHAR2(80);
    ckey5_used_table      VARCHAR2(80);

    ckey1_used_column     VARCHAR2(80);
    ckey2_used_column     VARCHAR2(80);
    ckey3_used_column     VARCHAR2(80);
    ckey4_used_column     VARCHAR2(80);
    ckey5_used_column     VARCHAR2(80);

    cxref_category_code   VARCHAR2(30);

    key1                  VARCHAR2(500);  --4011384
    key2                  VARCHAR2(500);
    key3                  VARCHAR2(500);
    key4                  VARCHAR2(500);
    key5                  VARCHAR2(500);

    ext1                  VARCHAR2(500);
    ext2                  VARCHAR2(500);
    ext3                  VARCHAR2(500);
    ext4                  VARCHAR2(500);
    ext5                  VARCHAR2(500);

    return_code           pls_integer;
    icount                pls_integer;
    l_return_status       VARCHAR2(2000);
    l_msg_count           pls_integer;
    l_msg_data            VARCHAR2(2000);

    i                     pls_integer;
    j                     pls_integer;
    l_ext_pos		  pls_integer;
    b_xref_data_found     BOOLEAN;

	BEGIN

  if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PUSH('EC_Code_Conversion_PVT.populate_plsql_tbl_with_extval');
   EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_commit: ',p_commit);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   end if;
	-- Standard Start of API savepoint
	SAVEPOINT populate_plsql_tbl_PVT;

	-- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
       (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list) THEN
				FND_MSG_PUB.initialize;
      END IF;

	-- Initialize API return status to success
	p_return_status := FND_API.G_RET_STS_SUCCESS;

	-- *******************************************************
	-- work on each row in the p_tbl pl/sql
	-- table to fill in the ext1-5 value
	-- *******************************************************
	icount := p_tbl.COUNT;

FOR i IN ec_utils.g_int_levels(p_level).file_start_pos..ec_utils.g_int_levels(p_level).file_end_pos
LOOP
        IF (p_tbl(i).xref_category_id IS NOT NULL) THEN
	-- use this xref_id, go to ece_xref_category to find out all the
	-- enabled keys
	SELECT	  key1_used_flag, key2_used_flag, key3_used_flag,
                  key4_used_flag, key5_used_flag,
                  key1_used_table, key2_used_table, key3_used_table,
                  key4_used_table, key5_used_table,
                  key1_used_column, key2_used_column, key3_used_column,
                  key4_used_column, key5_used_column,
                  xref_category_code
	INTO	  ckey1_used_flag, ckey2_used_flag, ckey3_used_flag,
                  ckey4_used_flag, ckey5_used_flag,
                  ckey1_used_table, ckey2_used_table, ckey3_used_table,
                  ckey4_used_table, ckey5_used_table,
                  ckey1_used_column, ckey2_used_column, ckey3_used_column,
                  ckey4_used_column, ckey5_used_column,
                  cxref_category_code
	FROM	  ece_xref_categories
	WHERE	  ece_xref_categories.xref_category_id = p_tbl(i).xref_category_id;

	-- Bug 2828072
          IF ckey1_used_flag = 'Y' AND
             p_tbl(i).xref_key1_source_column IS NOT NULL THEN
            FOR j IN REVERSE 1..p_level LOOP
              FOR k IN ec_utils.g_int_levels(j).file_start_pos..ec_utils.g_int_levels(j).file_end_pos
              LOOP
                IF p_tbl(i).xref_key1_source_column =
                 p_tbl(k).interface_column_name THEN
                	key1 := p_tbl(k).value;
			EXIT;
                END IF;
              END LOOP;
              IF key1 IS NOT NULL THEN
                EXIT;
              END IF;
	    END LOOP;
		-- we assume all the key can be found in the pl/sql table
	  END IF;

          IF ckey2_used_flag = 'Y' AND
             p_tbl(i).xref_key2_source_column IS NOT NULL THEN
            FOR j IN REVERSE 1..p_level LOOP
              FOR k IN ec_utils.g_int_levels(j).file_start_pos..ec_utils.g_int_levels(j).file_end_pos
              LOOP
                IF p_tbl(i).xref_key2_source_column =
                 p_tbl(k).interface_column_name THEN
                	key2 := p_tbl(k).value;
    			EXIT;
                END IF;
              END LOOP;
              IF key2 IS NOT NULL THEN
                EXIT;
	      END IF;
	    END LOOP;
	  END IF;

          IF ckey3_used_flag = 'Y' AND
            p_tbl(i).xref_key3_source_column IS NOT NULL THEN
            FOR j IN REVERSE 1..p_level LOOP
              FOR k IN ec_utils.g_int_levels(j).file_start_pos..ec_utils.g_int_levels(j).file_end_pos
              LOOP
                IF p_tbl(i).xref_key3_source_column =
                 p_tbl(k).interface_column_name THEN
               		 key3 := p_tbl(k).value;
                  	 EXIT;
	        END IF;
              END LOOP;
              IF key3 IS NOT NULL THEN
                EXIT;
	      END IF;
	    END LOOP;
	  END IF;

          IF ckey4_used_flag = 'Y' AND
             p_tbl(i).xref_key4_source_column IS NOT NULL THEN
            FOR j IN REVERSE 1..p_level LOOP
              FOR k IN ec_utils.g_int_levels(j).file_start_pos..ec_utils.g_int_levels(j).file_end_pos
              LOOP
                IF p_tbl(i).xref_key4_source_column =
                 p_tbl(k).interface_column_name THEN
			key4 := p_tbl(k).value;
  			EXIT;
	        END IF;
              END LOOP;
              IF key4 IS NOT NULL THEN
                EXIT;
	      END IF;
	    END LOOP;
	END IF;

          IF ckey5_used_flag = 'Y' AND
             p_tbl(i).xref_key5_source_column IS NOT NULL THEN
            FOR j IN REVERSE 1..p_level LOOP
              FOR k IN ec_utils.g_int_levels(j).file_start_pos..ec_utils.g_int_levels(j).file_end_pos
              LOOP
                IF p_tbl(i).xref_key5_source_column =
                 p_tbl(k).interface_column_name THEN
			key5 := p_tbl(k).value;
			EXIT;
                END IF;
              END LOOP;
              IF key5 IS NOT NULL THEN
                EXIT;
	      END IF;
	    END LOOP;
	END IF;

	IF EC_DEBUG.G_debug_level = 3 then
             	EC_DEBUG.PL(3, 'key1 :', key1);
             	EC_DEBUG.PL(3, 'key2 :', key2);
             	EC_DEBUG.PL(3, 'key3 :', key3);
             	EC_DEBUG.PL(3, 'key4 :', key4);
             	EC_DEBUG.PL(3, 'key5 :', key5);
        END IF;
	-- Now we know the int_value, the actual value of the key1-5,
	-- so we just need to call int_2_ext APIs to get the
	-- the ext1-5 value
          EC_Code_Conversion_PVT.Convert_from_int_to_ext
           (p_api_version_number  => 1.0,
            p_return_status       => l_return_status,
            p_msg_count           => l_msg_count,
            p_msg_data            => l_msg_data,
            p_Category            => cxref_category_code,
            p_Key1                => key1,
            p_Key2                => key2,
            p_Key3                => key3,
            p_Key4                => key4,
            p_Key5                => key5,
            p_Int_val             => p_tbl(i).value,
            p_Ext_val1            => ext1,
            p_Ext_val2            => ext2,
            p_Ext_val3            => ext3,
            p_Ext_val4            => ext4,
            p_Ext_val5            => ext5);

            p_tbl(i).ext_val1 := ext1;
            p_tbl(i).ext_val2 := ext2;
            p_tbl(i).ext_val3 := ext3;
            p_tbl(i).ext_val4 := ext4;
            p_tbl(i).ext_val5 := ext5;

            key1 := NULL;
            key2 := NULL;
            key3 := NULL;
            key4 := NULL;
            key5 := NULL;

           -- ******************************
           -- Need to populate the value column
           -- of all the corresponding external
           -- values, e.g. UOM_CODE_EXT1
           -- ******************************

           IF ext1 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext1 :', ext1);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_level       	=> p_level,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 1,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext1;
              END IF;
           END IF;

           IF ext2 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext2 :', ext2);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_level       => p_level,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 2,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext2;
              END IF;
           END IF;

           IF ext3 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext3 :', ext3);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_level       => p_level,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 3,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext3;
              END IF;
           END IF;

           IF ext4 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext4 :', ext4);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_level       => p_level,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 4,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext4;
              END IF;
           END IF;

           IF ext5 is NOT NULL
           THEN
             if EC_DEBUG.G_debug_level = 3 then
             EC_DEBUG.PL(3, 'ext5 :', ext5);
             end if;
             b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_level       => p_level,
              p_conversion_group  => p_tbl(i).conversion_group_id,
              p_sequence_num      => 5,
              p_Pos               => l_ext_pos);

              IF b_xref_data_found THEN
                 p_tbl(l_ext_pos).value := ext5;
              END IF;
           END IF;

        -- This is to copy the internal value to external value if
        -- there is no category code assigned to the interface column and
        -- the external value1 is null.

        ELSIF (p_tbl(i).conversion_sequence = 0) THEN
           b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
          (p_level       => p_level,
           p_conversion_group  => p_tbl(i).conversion_group_id,
           p_sequence_num      => 1,
           p_Pos               => l_ext_pos);

           IF b_xref_data_found THEN
              p_tbl(l_ext_pos).value := p_tbl(i).value;
              p_tbl(i).ext_val1 := p_tbl(i).value;
           END IF;

        END IF;
      END LOOP;

	-- *******************************************************
	-- Standard check of p_simulate and p_commit parameters
	-- *******************************************************
      IF FND_API.To_Boolean(p_simulate) THEN
				ROLLBACK TO populate_plsql_tbl_PVT;
      ELSIF FND_API.To_Boolean(p_commit) THEN
				COMMIT WORK;
	END IF;

      -- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);

      if l_return_status = EC_Code_Conversion_PVT.G_XREF_NOT_FOUND
      then
         p_return_status := EC_Code_Conversion_PVT.G_XREF_NOT_FOUND;
      end if;

  if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.POP('EC_Code_Conversion_PVT.populate_plsql_tbl_with_extval');
  end if;
EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO populate_plsql_tbl_PVT;
			p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
				ROLLBACK TO populate_plsql_tbl_PVT;
				p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);
      WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ROLLBACK TO populate_plsql_tbl_PVT;
	p_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
					FND_MSG_PUB.Add_Exc_Msg(G_FILE_NAME, G_PKG_NAME, l_api_name);
	END IF;
        FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);

END populate_plsql_tbl_with_extval;

  PROCEDURE populate_plsql_tbl_with_intval
   (p_api_version_number  IN        NUMBER,
    p_init_msg_list       IN        VARCHAR2      := FND_API.G_FALSE,
    p_simulate            IN        VARCHAR2      := FND_API.G_FALSE,
    p_commit              IN        VARCHAR2      := FND_API.G_FALSE,
    p_validation_level    IN        NUMBER        := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT NOCOPY  VARCHAR2,
    p_msg_count           OUT NOCOPY  NUMBER,
    p_msg_data            OUT NOCOPY      VARCHAR2,
    p_key_tbl             IN OUT NOCOPY   ece_flatfile_pvt.Interface_tbl_type,
    p_apps_tbl            IN OUT NOCOPY   ece_flatfile_pvt.Interface_tbl_type) IS

    l_api_name            CONSTANT  VARCHAR2(30)  := 'populate_plsql_tbl_with_intval';
    l_api_version_number  CONSTANT  NUMBER        := 1.0;

    ckey1_used_flag                 VARCHAR2(1);
    ckey2_used_flag                 VARCHAR2(1);
    ckey3_used_flag                 VARCHAR2(1);
    ckey4_used_flag                 VARCHAR2(1);
    ckey5_used_flag                 VARCHAR2(1);

    ckey1_used_table                VARCHAR2(80);
    ckey2_used_table                VARCHAR2(80);
    ckey3_used_table                VARCHAR2(80);
    ckey4_used_table                VARCHAR2(80);
    ckey5_used_table                VARCHAR2(80);

    ckey1_used_column               VARCHAR2(80);
    ckey2_used_column               VARCHAR2(80);
    ckey3_used_column               VARCHAR2(80);
    ckey4_used_column               VARCHAR2(80);
    ckey5_used_column               VARCHAR2(80);

    cxref_category_code             VARCHAR2(30);

    key1                            VARCHAR2(500); -- 4011384
    key2                            VARCHAR2(500);
    key3                            VARCHAR2(500);
    key4                            VARCHAR2(500);
    key5                            VARCHAR2(500);

    int_val                         VARCHAR2(500);
    c_ext_value1                    VARCHAR2(500);
    c_ext_value2                    VARCHAR2(500);
    c_ext_value3                    VARCHAR2(500);
    c_ext_value4                    VARCHAR2(500);
    c_ext_value5                    VARCHAR2(500);

    l_int_data_loc_pos              NUMBER;
    l_key_data_loc_pos              NUMBER;

    return_code                     NUMBER;
    icount                          NUMBER;
    l_return_status                 VARCHAR2(2000);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);

    b_xref_data_found               BOOLEAN       := FALSE;

    j                               INTEGER       := 1;
    k                               INTEGER;

		BEGIN
   if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PUSH('EC_Code_Conversion_PVT.populate_plsql_tbl_with_intval');
   EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_commit: ',p_commit);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   end if;
      -- Standard Start of API savepoint
			SAVEPOINT populate_plsql_tbl_PVT;

			-- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
       (l_api_version_number,
	p_api_version_number,
	l_api_name,
        G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

			-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
      END IF;

	-- Initialize API return status to success
	p_return_status := FND_API.G_RET_STS_SUCCESS;

	-- *******************************************************
	-- Move data from interface to source PL/SQL table
	-- These are data that do not need xref.
	-- *******************************************************
      WHILE j <= p_apps_tbl.count LOOP

          /* Debugging Code: DO NOT DELETE! */
	/*
	BEGIN
        INSERT INTO ece_error(run_id, line_id, text)
			VALUES(
				81,
				ece_error_s.nextval,
				'Rec =' || p_apps_tbl(j).record_num ||
				'- Pos= ' || p_apps_tbl(j).Position ||
				'- Val=' || p_apps_tbl(j).extvalue ||
				' Width= ' || p_apps_tbl(j).data_length ||
				' Int Col= '|| p_apps_tbl(j).interface_column_name ||
				'- Apps col= ' || p_apps_tbl(j).base_column_name ||
				'- val= '|| p_apps_tbl(j).value);
	EXCEPTION
        WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        END;
	*/

	-- *******************************************************
	-- If the data need xref to convert to internal value
	-- *******************************************************
        IF p_apps_tbl(j).xref_category_id IS NOT NULL AND
           p_apps_tbl(j).conversion_seq = 0 THEN

          -- *******************************************************
          -- These are data that need xref.
          -- First find all external values for xref.
          -- *******************************************************

          -- If the value is NOT NULL, the flat file already supplied
          -- the internal value and no XREF work needs to be done... (apark)
          IF p_apps_tbl(j).value IS NULL THEN

            -- We're going to go through each of the Conversion Seqs and
            -- see if they exist or not.

            -- 1
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_apps_tbl,
              p_conversion_group  => p_apps_tbl(j).conversion_group_id,
              p_sequence_num      => 1,
              p_Pos               => l_int_data_loc_pos);

            IF b_xref_data_found THEN
              c_ext_value1 := p_apps_tbl(l_int_data_loc_pos).value;
              if EC_DEBUG.G_debug_level >= 3 then
              EC_DEBUG.PL(3, 'c_ext_value1 :', c_ext_value1);
              end if;
            END IF;

            -- 2
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_apps_tbl,
              p_conversion_group  => p_apps_tbl(j).conversion_group_id,
              p_sequence_num      => 2,
              p_Pos               => l_int_data_loc_pos);

            IF b_xref_data_found THEN
              c_ext_value2 := p_apps_tbl(l_int_data_loc_pos).value;
              if EC_DEBUG.G_debug_level >= 3 then
              EC_DEBUG.PL(3, 'c_ext_value2 :', c_ext_value2);
              end if;
            END IF;

            -- 3
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_apps_tbl,
              p_conversion_group  => p_apps_tbl(j).conversion_group_id,
              p_sequence_num      => 3,
              p_Pos               => l_int_data_loc_pos);

            IF b_xref_data_found THEN
              c_ext_value3 := p_apps_tbl(l_int_data_loc_pos).value;
              if EC_DEBUG.G_debug_level >= 3 then
              EC_DEBUG.PL(3, 'c_ext_value3 :', c_ext_value3);
              end if;
            END IF;

            -- 4
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_apps_tbl,
              p_conversion_group  => p_apps_tbl(j).conversion_group_id,
              p_sequence_num      => 4,
              p_Pos               => l_int_data_loc_pos);

            IF b_xref_data_found THEN
              c_ext_value4 := p_apps_tbl(l_int_data_loc_pos).value;
              if EC_DEBUG.G_debug_level >= 3 then
              EC_DEBUG.PL(3, 'c_ext_value4 :', c_ext_value4);
              end if;
            END IF;

            -- 5
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
             (p_gateway_tbl       => p_apps_tbl,
              p_conversion_group  => p_apps_tbl(j).conversion_group_id,
              p_sequence_num      => 5,
              p_Pos               => l_int_data_loc_pos);

            IF b_xref_data_found THEN
              c_ext_value5 := p_apps_tbl(l_int_data_loc_pos).value;
              if EC_DEBUG.G_debug_level >= 3 then
              EC_DEBUG.PL(3, 'c_ext_value5 :', c_ext_value5);
              end if;
            END IF;

            -- ***************************************
            --
            --  Find out what is the xref catergory code
            --  The code is in the apps pl/sql table
            --  therefore, need to find the matching
            --  data loc id in apps pl/sql table
            --
            -- ***************************************

            -- use this xref_id, go to ece_xref_category to find out all the
            -- enabled keys
            SELECT  key1_used_flag, key2_used_flag, key3_used_flag,
                    key4_used_flag, key5_used_flag,
                    key1_used_table, key2_used_table, key3_used_table,
                    key4_used_table, key5_used_table,
                    key1_used_column, key2_used_column, key3_used_column,
                    key4_used_column, key5_used_column,
                    xref_category_code
            INTO    ckey1_used_flag, ckey2_used_flag, ckey3_used_flag,
                    ckey4_used_flag, ckey5_used_flag,
                    ckey1_used_table, ckey2_used_table, ckey3_used_table,
                    ckey4_used_table, ckey5_used_table,
                    ckey1_used_column, ckey2_used_column, ckey3_used_column,
                    ckey4_used_column, ckey5_used_column,
                    cxref_category_code
            FROM    ece_xref_categories
            WHERE   ece_xref_categories.xref_category_id = p_apps_tbl(j).xref_category_id;

            IF ckey1_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key1_source_column IS NOT NULL THEN
              FOR k IN 1..p_key_tbl.count LOOP
                IF p_apps_tbl(j).xref_key1_source_column =
                   p_key_tbl(k).interface_column_name THEN
                  key1 := p_key_tbl(k).value;
                  if EC_DEBUG.G_debug_level >= 3 then
                  EC_DEBUG.PL(3, 'key1 :', key1);
                  end if;
                  EXIT;
                END IF;
              END LOOP;
              -- we assume all the key can be found in the pl/sql table
            END IF;

            -- 2
            IF ckey2_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key2_source_column IS NOT NULL THEN
              FOR k IN 1..p_key_tbl.count LOOP
                IF p_apps_tbl(j).xref_key2_source_column =
                   p_key_tbl(k).interface_column_name THEN
                  key2 := p_key_tbl(k).value;
                  if EC_DEBUG.G_debug_level >= 3 then
                  EC_DEBUG.PL(3, 'key2 :', key2);
                  end if;
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            -- 3
            IF ckey3_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key3_source_column IS NOT NULL THEN
              FOR k IN 1..p_key_tbl.count LOOP
                IF p_apps_tbl(j).xref_key3_source_column =
                   p_key_tbl(k).interface_column_name THEN
                  key3 := p_key_tbl(k).value;
                  if EC_DEBUG.G_debug_level >= 3 then
                  EC_DEBUG.PL(3, 'key3 :', key3);
                  end if;
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            -- 4
            IF ckey4_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key4_source_column IS NOT NULL THEN
              FOR k IN 1..p_key_tbl.count LOOP
                IF p_apps_tbl(j).xref_key4_source_column =
                   p_key_tbl(k).interface_column_name THEN
                  key4 := p_key_tbl(k).value;
                  if EC_DEBUG.G_debug_level >= 3 then
                  EC_DEBUG.PL(3, 'key4 :', key4);
                  end if;
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            -- 5
            IF ckey5_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key5_source_column IS NOT NULL THEN
              FOR k IN 1..p_key_tbl.count LOOP
                IF p_apps_tbl(j).xref_key5_source_column =
                   p_key_tbl(k).interface_column_name THEN
                  key5 := p_key_tbl(k).value;
                  if EC_DEBUG.G_debug_level >= 3 then
                  EC_DEBUG.PL(3, 'key5 :', key5);
                  end if;
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            /* Debugging Code: DO NOT DELETE! */
            /*
            IF (debug_mode_on_int) THEN
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'xref code =' || cxref_category_code);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'column =' || p_apps_tbl(j).interface_column_name);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'key 1 =' || key1);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'key 2 =' || key2);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'key 3 =' || key3);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'key 4 =' || key4);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'key 5 =' || key5);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'ext 1 =' || c_ext_value1);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'ext 2 =' || c_ext_value2);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'ext 3 =' || c_ext_value3);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'ext 4 =' || c_ext_value4);
              INSERT INTO ece_error VALUES (431, ece_error_s.nextval, 'ext 5 =' || c_ext_value5);
              COMMIT;
            END IF;
            */

            -- Now we know the int_value, the actual value of the key1-5,
            -- so we just need to call int_2_ext APIs to get the
            -- the ext1-5 value
            EC_Code_Conversion_PVT.Convert_from_ext_to_int
             (p_api_version_number  => 1.0,
              p_return_status       => l_return_status,
              p_msg_count           => l_msg_count,
              p_msg_data            => l_msg_data,
              p_Category            => cxref_category_code,
              p_Key1                => key1,
              p_Key2                => key2,
              p_Key3                => key3,
              p_Key4                => key4,
              p_Key5                => key5,
              p_Ext_val1            => c_ext_value1,
              p_Ext_val2            => c_ext_value2,
              p_Ext_val3            => c_ext_value3,
              p_Ext_val4            => c_ext_value4,
              p_Ext_val5            => c_ext_value5,
              p_Int_val             => int_val);

            p_apps_tbl(j).value := int_val;
            if EC_DEBUG.G_debug_level >= 3 then
            EC_DEBUG.PL(3, 'int_val :', int_val);
            end if;
            key1 := NULL;
            key2 := NULL;
            key3 := NULL;
            key4 := NULL;
            key5 := NULL;

            c_ext_value1 := NULL;
            c_ext_value2 := NULL;
            c_ext_value3 := NULL;
            c_ext_value4 := NULL;
            c_ext_value5 := NULL;
          END IF; -- IF p_apps_tbl(j).value IS NULL THEN

        -- This is to copy the external value1 to internal value if
        -- there is no category code assigned to the interface column and
        -- the internal value is null.
        ELSIF (p_apps_tbl(j).xref_category_id is NULL AND
               p_apps_tbl(j).conversion_seq = 0 AND
               p_apps_tbl(j).value is NULL) THEN

            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
       	      	(
		p_gateway_tbl		=> p_apps_tbl,
              	p_conversion_group  	=> p_apps_tbl(j).conversion_group_id,
              	p_sequence_num      	=> 1,
              	p_Pos               	=> l_int_data_loc_pos
		);

            IF b_xref_data_found THEN
              c_ext_value1 := p_apps_tbl(l_int_data_loc_pos).value;
              if (c_ext_value1 is not null) then
                 if EC_DEBUG.G_debug_level >= 3 then
                 EC_DEBUG.PL(3, 'c_ext_value1 :', c_ext_value1);
                 end if;
              p_apps_tbl(j).value := c_ext_value1;
              end if;
            END IF;

        END IF; -- IF p_apps_tbl(j).xref_category_id IS NOT NULL AND p_apps_tbl(j).conversion_seq = 0 THEN
        j := j + 1;
      END LOOP; --WHILE j <= p_apps_tbl.count LOOP

	-- *******************************************************
	-- Standard check of p_simulate and p_commit parameters
	-- *******************************************************
      IF FND_API.To_Boolean(p_simulate) THEN
        ROLLBACK TO populate_plsql_tbl_PVT;
      ELSIF FND_API.To_Boolean(p_commit) THEN
	COMMIT WORK;
      END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);

      if l_return_status = EC_Code_Conversion_PVT.G_XREF_NOT_FOUND
      then
         p_return_status := EC_Code_Conversion_PVT.G_XREF_NOT_FOUND;
      end if;

    if EC_DEBUG.G_debug_level >= 2 then
      EC_DEBUG.POP('EC_Code_Conversion_PVT.populate_plsql_tbl_with_intval');
    end if;
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO populate_plsql_tbl_PVT;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
					  p_data  => p_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO populate_plsql_tbl_PVT;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
					  p_data  => p_msg_data);
      WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
		ROLLBACK TO populate_plsql_tbl_PVT;
		p_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
					FND_MSG_PUB.Add_Exc_Msg(G_FILE_NAME, G_PKG_NAME, l_api_name);
	END IF;
		FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
					  p_data  => p_msg_data);
	END populate_plsql_tbl_with_intval;

PROCEDURE populate_plsql_tbl_with_intval
   	(
	p_api_version_number  	IN        	NUMBER,
	p_init_msg_list       	IN        	VARCHAR2      := FND_API.G_FALSE,
	p_simulate            	IN        	VARCHAR2      := FND_API.G_FALSE,
	p_commit              	IN        	VARCHAR2      := FND_API.G_FALSE,
	p_validation_level    	IN        	NUMBER        := FND_API.G_VALID_LEVEL_FULL,
	p_return_status       	OUT  NOCOPY      	VARCHAR2,
	p_msg_count           	OUT  NOCOPY     	NUMBER,
	p_msg_data            	OUT  NOCOPY     	VARCHAR2,
	p_apps_tbl            	IN OUT NOCOPY 	ec_utils.mapping_tbl,
	p_level			IN		NUMBER
	) IS


    l_api_name            CONSTANT  VARCHAR2(30)  := 'populate_plsql_tbl_with_intval';
    l_api_version_number  CONSTANT  NUMBER        := 1.0;

    ckey1_used_flag                 VARCHAR2(1);
    ckey2_used_flag                 VARCHAR2(1);
    ckey3_used_flag                 VARCHAR2(1);
    ckey4_used_flag                 VARCHAR2(1);
    ckey5_used_flag                 VARCHAR2(1);

    ckey1_used_table                VARCHAR2(80);
    ckey2_used_table                VARCHAR2(80);
    ckey3_used_table                VARCHAR2(80);
    ckey4_used_table                VARCHAR2(80);
    ckey5_used_table                VARCHAR2(80);

    ckey1_used_column               VARCHAR2(80);
    ckey2_used_column               VARCHAR2(80);
    ckey3_used_column               VARCHAR2(80);
    ckey4_used_column               VARCHAR2(80);
    ckey5_used_column               VARCHAR2(80);

    cxref_category_code             VARCHAR2(30);

    key1                            VARCHAR2(500); -- 4011384
    key2                            VARCHAR2(500);
    key3                            VARCHAR2(500);
    key4                            VARCHAR2(500);
    key5                            VARCHAR2(500);

    int_val                         VARCHAR2(500);
    c_ext_value1                    VARCHAR2(500);
    c_ext_value2                    VARCHAR2(500);
    c_ext_value3                    VARCHAR2(500);
    c_ext_value4                    VARCHAR2(500);
    c_ext_value5                    VARCHAR2(500);

    l_int_data_loc_pos              NUMBER;
    l_key_data_loc_pos              NUMBER;

    return_code                     NUMBER;
    icount                          NUMBER;
    l_return_status                 VARCHAR2(2000);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);

    b_xref_data_found               BOOLEAN       := FALSE;

    k                               INTEGER;

BEGIN
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PUSH('EC_Code_Conversion_PVT.populate_plsql_tbl_with_intval');
EC_DEBUG.PL(3, 'API version : ',p_api_version_number);
EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
EC_DEBUG.PL(3, 'p_commit: ',p_commit);
EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
EC_DEBUG.PL(3, 'p_level',p_level);
end if;
      -- Standard Start of API savepoint
			SAVEPOINT populate_plsql_tbl_PVT;

			-- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
       (l_api_version_number,
	p_api_version_number,
	l_api_name,
        G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

			-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
      END IF;

	-- Initialize API return status to success
	p_return_status := FND_API.G_RET_STS_SUCCESS;

	-- *******************************************************
	-- Move data from interface to source PL/SQL table
	-- These are data that do not need xref.
	-- *******************************************************
for j in ec_utils.g_ext_levels(p_level).file_start_pos..ec_utils.g_ext_levels(p_level).file_end_pos
LOOP

        -- This is to copy the external value1 to internal value if
        -- there is no category code assigned to the interface column and
        -- the internal value is null.
	-- Bug 2708573
	-- Moved the ELSIF to the begin of IF, as less time is consumed
	-- for IS NULL check as compared to IS NOT NULL.
        IF p_apps_tbl(j).xref_category_id is NULL THEN

          IF p_apps_tbl(j).conversion_sequence = 0 AND
               p_apps_tbl(j).value is NULL THEN

            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
                (
                p_level                 => p_level,
                p_conversion_group      => p_apps_tbl(j).conversion_group_id,
                p_sequence_num          => 1,
                p_Pos                   => l_int_data_loc_pos
                );

            IF b_xref_data_found THEN
              c_ext_value1 := p_apps_tbl(l_int_data_loc_pos).value;
              if (c_ext_value1 is not null) then
                 p_apps_tbl(j).value := c_ext_value1;
              end if;
            END IF;
            if EC_DEBUG.G_debug_level >= 3 then
            	ec_debug.pl(3,'Interface Column Name ',p_apps_tbl(j).Interface_Column_Name);
            	ec_debug.pl(3,'Internal Value ',p_apps_tbl(j).value);
                EC_DEBUG.PL(3, 'c_ext_value1 :', c_ext_value1);
            end if;
	  END IF;

	-- *******************************************************
	-- If the data need xref to convert to internal value
	-- *******************************************************
        ELSE
	   -- Bug 2708573
	   -- Removed p_apps_tbl(j).xref_category_id IS NOT NULL check
	   -- in the condition below.

	   IF p_apps_tbl(j).conversion_sequence = 0 AND
              p_apps_tbl(j).value IS NULL THEN

            if EC_DEBUG.G_debug_level >= 3 then
	      ec_debug.pl(3,'Interface Column Name ',p_apps_tbl(j).Interface_Column_Name);
	      ec_debug.pl(3,'Internal Value ',p_apps_tbl(j).value);
            end if;
            -- *******************************************************
            -- These are data that need xref.
            -- First find all external values for xref.
            -- *******************************************************

            -- If the value is NOT NULL, the flat file already supplied
            -- the internal value and no XREF work needs to be done... (apark)
            -- IF p_apps_tbl(j).value IS NULL THEN : Bug 2708573

            -- We're going to go through each of the Conversion Seqs and
            -- see if they exist or not.

            -- 1
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
       	      	(
		p_level			=> p_level ,
              	p_conversion_group  	=> p_apps_tbl(j).conversion_group_id,
              	p_sequence_num      	=> 1,
              	p_Pos               	=> l_int_data_loc_pos
		);

            IF b_xref_data_found THEN
              c_ext_value1 := p_apps_tbl(l_int_data_loc_pos).value;
            END IF;

            -- 2
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
       	      	(
		p_level			=> p_level ,
              	p_conversion_group  	=> p_apps_tbl(j).conversion_group_id,
              	p_sequence_num      	=> 2,
              	p_Pos               	=> l_int_data_loc_pos
		);

            IF b_xref_data_found THEN
              c_ext_value2 := p_apps_tbl(l_int_data_loc_pos).value;
            END IF;

            -- 3
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
       	      	(
		p_level			=> p_level ,
              	p_conversion_group  	=> p_apps_tbl(j).conversion_group_id,
              	p_sequence_num      	=> 3,
              	p_Pos               	=> l_int_data_loc_pos
		);

            IF b_xref_data_found THEN
              c_ext_value3 := p_apps_tbl(l_int_data_loc_pos).value;
            END IF;

            -- 4
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
       	      	(
		p_level			=> p_level ,
              	p_conversion_group  	=> p_apps_tbl(j).conversion_group_id,
              	p_sequence_num      	=> 4,
              	p_Pos               	=> l_int_data_loc_pos
		);

            IF b_xref_data_found THEN
              c_ext_value4 := p_apps_tbl(l_int_data_loc_pos).value;
            END IF;

            -- 5
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
       	      	(
		p_level			=> p_level ,
              	p_conversion_group  	=> p_apps_tbl(j).conversion_group_id,
              	p_sequence_num      	=> 5,
              	p_Pos               	=> l_int_data_loc_pos
		);

            IF b_xref_data_found THEN
              c_ext_value5 := p_apps_tbl(l_int_data_loc_pos).value;
            END IF;

              if EC_DEBUG.G_debug_level >= 3 then
              EC_DEBUG.PL(3, 'c_ext_value1 :', c_ext_value1);
              EC_DEBUG.PL(3, 'c_ext_value2 :', c_ext_value2);
              EC_DEBUG.PL(3, 'c_ext_value3 :', c_ext_value3);
              EC_DEBUG.PL(3, 'c_ext_value4 :', c_ext_value4);
              EC_DEBUG.PL(3, 'c_ext_value5 :', c_ext_value5);
              end if;
            -- ***************************************
            --
            --  Find out what is the xref catergory code
            --  The code is in the apps pl/sql table
            --  therefore, need to find the matching
            --  data loc id in apps pl/sql table
            --
            -- ***************************************

            -- use this xref_id, go to ece_xref_category to find out all the
            -- enabled keys
            SELECT  key1_used_flag, key2_used_flag, key3_used_flag,
                    key4_used_flag, key5_used_flag,
                    key1_used_table, key2_used_table, key3_used_table,
                    key4_used_table, key5_used_table,
                    key1_used_column, key2_used_column, key3_used_column,
                    key4_used_column, key5_used_column,
                    xref_category_code
            INTO    ckey1_used_flag, ckey2_used_flag, ckey3_used_flag,
                    ckey4_used_flag, ckey5_used_flag,
                    ckey1_used_table, ckey2_used_table, ckey3_used_table,
                    ckey4_used_table, ckey5_used_table,
                    ckey1_used_column, ckey2_used_column, ckey3_used_column,
                    ckey4_used_column, ckey5_used_column,
                    cxref_category_code
            FROM    ece_xref_categories
            WHERE   ece_xref_categories.xref_category_id = p_apps_tbl(j).xref_category_id;
               if EC_DEBUG.G_debug_level >= 3 then
            	ec_debug.pl(3,'xref_category_id',p_apps_tbl(j).xref_category_id);
		ec_debug.pl(3,'cxref_category_code',cxref_category_code);
               end if;

	   -- Bug 2828072
            IF ckey1_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key1_source_column IS NOT NULL THEN
              FOR k IN REVERSE 1..p_level LOOP
	        FOR i in ec_utils.g_ext_levels(k).file_start_pos..ec_utils.g_ext_levels(k).file_end_pos
		LOOP
                  IF p_apps_tbl(j).xref_key1_source_column =
                   p_apps_tbl(i).interface_column_name THEN
                 	 key1 := p_apps_tbl(i).value;
                  	 EXIT;
                  END IF;
		END LOOP;
		IF key1 IS NOT NULL THEN
                  EXIT;
                END IF;
              END LOOP;
              -- we assume all the key can be found in the pl/sql table
            END IF;

            -- 2
            IF ckey2_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key2_source_column IS NOT NULL THEN
              FOR k IN REVERSE 1..p_level LOOP
	        FOR i in ec_utils.g_ext_levels(k).file_start_pos..ec_utils.g_ext_levels(k).file_end_pos
		LOOP
                 IF p_apps_tbl(j).xref_key2_source_column =
                   p_apps_tbl(i).interface_column_name THEN
                  	key2 := p_apps_tbl(i).value;
			EXIT;
                  END IF;
		END LOOP;
		IF key2 IS NOT NULL THEN
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            -- 3
            IF ckey3_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key3_source_column IS NOT NULL THEN
              FOR k IN REVERSE 1..p_level LOOP
	        FOR i in ec_utils.g_ext_levels(k).file_start_pos..ec_utils.g_ext_levels(k).file_end_pos
		LOOP
                  IF p_apps_tbl(j).xref_key3_source_column =
                   p_apps_tbl(i).interface_column_name THEN  --bug 4136922
                  	key3 := p_apps_tbl(i).value;
                  	EXIT;
                  END IF;
		END LOOP;
		IF key3 IS NOT NULL THEN
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            -- 4
            IF ckey4_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key4_source_column IS NOT NULL THEN
              FOR k IN REVERSE 1..p_level LOOP
	        FOR i in ec_utils.g_ext_levels(k).file_start_pos..ec_utils.g_ext_levels(k).file_end_pos
		LOOP
                  IF p_apps_tbl(j).xref_key4_source_column =
                   p_apps_tbl(i).interface_column_name THEN
                  	key4 := p_apps_tbl(i).value;
                  	EXIT;
                  END IF;
		END LOOP;
		IF key4 IS NOT NULL THEN
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            -- 5
            IF ckey5_used_flag = 'Y' AND
               p_apps_tbl(j).xref_key5_source_column IS NOT NULL THEN
              FOR k IN REVERSE 1..p_level LOOP
	        FOR i in ec_utils.g_ext_levels(k).file_start_pos..ec_utils.g_ext_levels(k).file_end_pos
		LOOP
                  IF p_apps_tbl(j).xref_key5_source_column =
                   p_apps_tbl(i).interface_column_name THEN
                  	key5 := p_apps_tbl(i).value;
                  	EXIT;
                  END IF;
		END LOOP;
		IF key5 IS NOT NULL THEN
                  EXIT;
                END IF;
              END LOOP;
            END IF;

            IF EC_DEBUG.G_debug_level = 3 THEN
              EC_DEBUG.PL(3, 'key1 :', key1);
              EC_DEBUG.PL(3, 'key2 :', key2);
              EC_DEBUG.PL(3, 'key3 :', key3);
              EC_DEBUG.PL(3, 'key4 :', key4);
              EC_DEBUG.PL(3, 'key5 :', key5);
	    END IF;

            -- Now we know the int_value, the actual value of the key1-5,
            -- so we just need to call int_2_ext APIs to get the
            -- the ext1-5 value
            EC_Code_Conversion_PVT.Convert_from_ext_to_int
             (p_api_version_number  => 1.0,
              p_return_status       => l_return_status,
              p_msg_count           => l_msg_count,
              p_msg_data            => l_msg_data,
              p_Category            => cxref_category_code,
              p_Key1                => key1,
              p_Key2                => key2,
              p_Key3                => key3,
              p_Key4                => key4,
              p_Key5                => key5,
              p_Ext_val1            => c_ext_value1,
              p_Ext_val2            => c_ext_value2,
              p_Ext_val3            => c_ext_value3,
              p_Ext_val4            => c_ext_value4,
              p_Ext_val5            => c_ext_value5,
              p_Int_val             => int_val);

            p_apps_tbl(j).value := int_val;
            if EC_DEBUG.G_debug_level >= 3 then
            EC_DEBUG.PL(3, 'Internal value after code conversion:', int_val);
            end if;
            key1 := NULL;
            key2 := NULL;
            key3 := NULL;
            key4 := NULL;
            key5 := NULL;

            c_ext_value1 := NULL;
            c_ext_value2 := NULL;
            c_ext_value3 := NULL;
            c_ext_value4 := NULL;
            c_ext_value5 := NULL;
          END IF; -- IF p_apps_tbl(j).value IS NULL THEN

         -- This is to copy the external value1 to internal value if
         -- there is no category code assigned to the interface column and
         -- the internal value is null.
	 /* Bug 2708573
          ELSIF (p_apps_tbl(j).xref_category_id is NULL AND
               p_apps_tbl(j).conversion_sequence = 0 AND
               p_apps_tbl(j).value is NULL) THEN
            if EC_DEBUG.G_debug_level >= 3 then
	    ec_debug.pl(3,'Interface Column Name ',p_apps_tbl(j).Interface_Column_Name);
	    ec_debug.pl(3,'Internal Value ',p_apps_tbl(j).value);
            end if;
            b_xref_data_found := ece_flatfile_pvt.match_xref_conv_seq
       	      	(
		p_level			=> p_level,
              	p_conversion_group  	=> p_apps_tbl(j).conversion_group_id,
              	p_sequence_num      	=> 1,
              	p_Pos               	=> l_int_data_loc_pos
		);

            IF b_xref_data_found THEN
              c_ext_value1 := p_apps_tbl(l_int_data_loc_pos).value;
              if (c_ext_value1 is not null) then
                 if EC_DEBUG.G_debug_level >= 3 then
                 EC_DEBUG.PL(3, 'c_ext_value1 :', c_ext_value1);
                 end if;
                 p_apps_tbl(j).value := c_ext_value1;
              end if;
            END IF;
	 */
        END IF; -- IF p_apps_tbl(j).xref_category_id IS NOT NULL AND p_apps_tbl(j).conversion_sequence = 0 THEN

END LOOP;

	-- *******************************************************
	-- Standard check of p_simulate and p_commit parameters
	-- *******************************************************
      IF FND_API.To_Boolean(p_simulate) THEN
        ROLLBACK TO populate_plsql_tbl_PVT;
      ELSIF FND_API.To_Boolean(p_commit) THEN
	COMMIT WORK;
      END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				  p_data  => p_msg_data);

      if l_return_status = EC_Code_Conversion_PVT.G_XREF_NOT_FOUND
      then
         p_return_status := EC_Code_Conversion_PVT.G_XREF_NOT_FOUND;
      end if;

if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.POP('EC_Code_Conversion_PVT.populate_plsql_tbl_with_intval');
end if;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO populate_plsql_tbl_PVT;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
					  p_data  => p_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO populate_plsql_tbl_PVT;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
					  p_data  => p_msg_data);
WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
		ROLLBACK TO populate_plsql_tbl_PVT;
		p_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
					FND_MSG_PUB.Add_Exc_Msg(G_FILE_NAME, G_PKG_NAME, l_api_name);
	END IF;
		FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
					  p_data  => p_msg_data);
END populate_plsql_tbl_with_intval;

END EC_Code_Conversion_PVT;

/
