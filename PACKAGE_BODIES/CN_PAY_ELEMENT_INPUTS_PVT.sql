--------------------------------------------------------
--  DDL for Package Body CN_PAY_ELEMENT_INPUTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAY_ELEMENT_INPUTS_PVT" AS
/* $Header: cnvqpib.pls 115.7 2002/11/21 21:16:25 hlchen ship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_QUOTA_PAY_ELEMENT_INPUT_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvqpeb.pls';
G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := FND_GLOBAL.USER_ID;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := FND_GLOBAL.USER_ID;
G_LAST_UPDATE_LOGIN         NUMBER  := FND_GLOBAL.LOGIN_ID;

G_PROGRAM_TYPE              VARCHAR2(30);

--|========================================================================
--| procedure : get object  ID
--| Desc :
--|========================================================================
PROCEDURE  get_object_id( p_object_name  IN VARCHAR2,
                         p_object_type  IN VARCHAR2,
                         p_table_id     IN NUMBER,
                         x_tab_col_name OUT NOCOPY VARCHAR2,
                         x_object_id    OUT NOCOPY NUMBER) IS
BEGIN

   IF p_object_type = 'COL' THEN

   SELECT object_id, NAME INTO x_object_id, x_tab_col_name
     FROM cn_objects
     WHERE user_name = p_object_name
      AND object_type = p_object_type
      AND table_id =    p_table_id;

   ELSE

   SELECT object_id, name INTO x_object_id, x_tab_col_name
     FROM cn_objects
     WHERE user_name = p_object_name
      AND object_type = p_object_type
      AND name IN ( 'CN_PAYMENT_TRANSACTIONS', 'CN_PAYRUNS', 'CN_SALESREPS');
   END IF;

EXCEPTION
   WHEN no_data_found THEN
      x_object_id := NULL;
END get_object_id;

--|========================================================================
--| Procedure : valid_pei_mapping
--| Desc : Procedure to validate quota pay element_input mapping
--|========================================================================
 PROCEDURE valid_pei_mapping
  (
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER   ,
   x_msg_data               OUT NOCOPY VARCHAR2 ,
   p_pay_element_input_rec  IN  pay_element_input_rec_type
                            := G_MISS_PAY_ELEMENT_INPUT_REC,
   p_table_name		    IN VARCHAR2,
   p_column_name            IN VARCHAR2,
   p_action                 IN VARCHAR2,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   )
  IS
     l_api_name      CONSTANT VARCHAR2(30) := 'Valid_Pei_Mapping';
     l_null_date     CONSTANT DATE         := to_date('31-12-4000','DD-MM-YYYY');

     l_dummy         NUMBER;
     l_count  	     NUMBER;

     l_id      NUMBER;

    l_effective_start_date     	DATE;
    l_effective_end_date   	DATE;


BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;
   -- API body

  --
  -- Only One column is allowed from posting detail
  --
  IF p_table_name = 'CN_POSTING_DETAILS' and
        p_column_name <> 'PAYMENT_AMOUNT' THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_CANNOT_USE_OTHER_COL');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_CANNOT_USE_OTHER_COL';
	 RAISE FND_API.G_EXC_ERROR ;
   END IF;

  --
  -- check table name is not null
  --
  IF  p_pay_element_input_rec.table_name IS NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_TABLE_NAME_NOT_NULL');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_TABLE_NAME_NOT_NULL';
	 RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --
  -- check col name is not null
  --
  IF  p_pay_element_input_rec.column_name IS NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_COL_NAME_NOT_NULL');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_COLUMN_NAME_NOT_NULL';
	 RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --
  -- check input exists and line number exists
  --
  IF  p_pay_element_input_rec.quota_pay_element_id IS  NULL
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_PAY_ELEMENT_MAP_NOT_EXISTS');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_PAY_ELEMENT_MAP_NOT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
   END IF;


   --
   -- check element input_id and line number is not null
   --
   IF  p_pay_element_input_rec.element_input_id IS  NULL or
        p_pay_element_input_rec.line_number IS  NULL THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_ELEMENT_INPUT_NOT_EXISTS');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_ELEMENT_INPUT_NOT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
    END IF;

   -- check table id exists
   IF  p_pay_element_input_rec.table_name IS NOT NULL and
      p_pay_element_input_rec.tab_object_id IS NULL THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_TABLE_NAME_NOT_EXISTS');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_TABLE_NAME_NOT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- check column id is exists
   IF  p_pay_element_input_rec.column_name IS NOT NULL and
      p_pay_element_input_rec.col_object_id IS NULL THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_COL_NAME_NOT_EXISTS');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_COL_NAME_NOT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
   END IF;

  --
  -- duplication of payment Amount is not allowed
  --
  IF P_table_name = 'CN_POSTING_DETAILS' and
     p_column_name = 'PAYMENT_AMOUNT' THEN

  -- Check for duplicate
  BEGIN
    SELECT 1 INTO l_dummy FROM dual
      WHERE NOT EXISTS
      ( SELECT 1
	FROM cn_pay_element_inputs
	WHERE tab_object_id =  p_pay_element_input_rec.tab_object_id
	AND   col_object_id = p_pay_element_input_rec.col_object_id
        AND   element_type_id = p_pay_element_input_rec.element_type_id
        AND   quota_pay_element_id = p_pay_element_input_rec.quota_pay_element_id
	AND   ((p_pay_element_input_rec.pay_element_input_id IS NOT NULL AND
		pay_element_input_id <> p_pay_element_input_rec.pay_element_input_id)
	       OR
	       (p_pay_element_input_rec.pay_element_input_id IS NULL))
       );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_DUPLICATE_AMOUNT_INPUT');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_DUPLICATE_AMOUNT_INPUT';
	 RAISE FND_API.G_EXC_ERROR ;
   END;

  END IF;

  --
  -- Check for Element input exist in Payroll
  --
     SELECT count(*) INTO l_count
       FROM
        pay_input_values_f  piv,
        pay_element_types_f pet,
        cn_quota_pay_elements cqpe,
        gl_sets_of_books glsob,
        cn_repositories cnr
      where
           cnr.set_of_books_id      = glsob.set_of_books_id
       AND pet.input_currency_code = glsob.currency_code
       AND cqpe.quota_pay_element_id   = p_pay_element_input_rec.quota_pay_element_id
       AND cqpe.pay_element_type_id = pet.element_type_id
       AND cqpe.start_date         >= pet.effective_start_date
       AND cqpe.end_date           <= pet.effective_end_date
       AND pet.effective_start_date>= piv.effective_start_date
       AND pet.effective_end_date  <= piv.effective_end_date
       AND pet.element_type_id     =  piv.element_type_id
       AND piv.element_type_id     =  pet.element_type_id
       AND piv.input_value_id      =  p_pay_element_input_rec.element_input_id
       AND piv.display_sequence	   =  p_pay_element_input_rec.line_number
       AND  pet.element_type_id    =  piv.element_type_id ;

       -- If zero then input value not found
      IF l_count = 0 THEN

	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_INPUT_VALUES_NOT_FOUND');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_INPUT_VALUES_NOT_FOUND';
	 RAISE FND_API.G_EXC_ERROR ;

      END IF;

      -- End of validation

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

END valid_pei_mapping;
--|========================================================================
--| Procedure : Create_pay_element_input
--| Desc : Procedure to create a new pay element_input input
--|========================================================================

PROCEDURE Create_pay_element_input
  (
   p_api_version           IN    NUMBER,
   p_init_msg_list	   IN    VARCHAR2,
   p_commit	           IN    VARCHAR2,
   p_validation_level      IN    NUMBER,
   x_return_status	   OUT NOCOPY   VARCHAR2,
   x_msg_count	           OUT NOCOPY   NUMBER,
   x_msg_data	           OUT NOCOPY   VARCHAR2,
   p_pay_element_input_rec IN    pay_element_input_rec_type
                              := G_MISS_PAY_ELEMENT_INPUT_REC,
   x_pay_element_input_id  OUT NOCOPY   NUMBER,
   x_loading_status        OUT NOCOPY   VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Pay_Element_Input';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_pay_element_input_rec  pay_element_input_rec_type := G_MISS_PAY_ELEMENT_INPUT_REC;
      l_action       VARCHAR2(30) := 'CREATE';

      l_table_name   cn_objects.name%TYPE;
      l_column_name  cn_objects.name%TYPE;


BEGIN
   x_pay_element_input_id := 0;

    -- Standard Start of API savepoint
   SAVEPOINT	Create_pay_element_input;
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

   l_pay_element_input_rec := p_pay_element_input_rec;

   -- Trim spaces before/after user input string, get Value-Id para assigned
   SELECT  p_pay_element_input_rec.quota_pay_element_id,
           p_pay_element_input_rec.element_type_id,
           p_pay_element_input_rec.line_number,
           p_pay_element_input_rec.element_input_id,
     Decode(p_pay_element_input_rec.table_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_pay_element_input_rec.table_name),
     Decode(p_pay_element_input_rec.column_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_pay_element_input_rec.column_name)
     INTO
      l_pay_element_input_rec.quota_pay_element_id,
      l_pay_element_input_rec.element_type_id,
      l_pay_element_input_rec.line_number,
      l_pay_element_input_rec.element_input_id,
      l_pay_element_input_rec.table_name,
      l_pay_element_input_rec.column_name
     FROM dual;

    -- get table

     get_object_id(l_pay_element_input_rec.table_name,
                   'TBL',
                    null,
                    l_table_name,
                    l_pay_element_input_rec.tab_object_id);


    -- get column
     get_object_id(l_pay_element_input_rec.column_name,
                   'COL',
                    l_pay_element_input_rec.tab_object_id,
                    l_column_name,
                    l_pay_element_input_rec.col_object_id );

   --
   -- Valid payment plan assignment
   --

    valid_pei_mapping
     ( x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_pay_element_input_rec => l_pay_element_input_rec,
       p_table_name	       => l_table_name,
       p_column_name           => l_column_name,
       p_action                => l_action,
       p_loading_status        => x_loading_status,
       x_loading_status        => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSE
    -- Create cn_pay_element_inputs

      cn_pay_element_inputs_pkg.insert_row
	(x_pay_element_input_id => l_pay_element_input_rec.pay_element_input_id
	,p_quota_pay_element_id => l_pay_element_input_rec.quota_pay_element_id
        ,p_element_input_id     => l_pay_element_input_rec.element_input_id
        ,p_element_type_id	=> l_pay_element_input_rec.element_type_id
        ,p_tab_object_id        => l_pay_element_input_rec.tab_object_id
        ,p_col_object_id        => l_pay_element_input_rec.col_object_id
        ,p_line_number	        => null -- we are not mainited here
        ,p_start_date	        => null -- not using now
        ,p_end_date	        => null -- not using now
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
      ROLLBACK TO Create_pay_element_input;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_pay_element_input;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_pay_element_input;
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

  END create_pay_element_input;

--|========================================================================
--| Procedure : Update_pay_element_input
--| Desc :
--|========================================================================

PROCEDURE Update_pay_element_input
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list	IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   po_pay_element_input_rec IN  pay_element_input_rec_type
                              := G_MISS_pay_element_input_rec,
   p_pay_element_input_rec IN pay_element_input_rec_type:=G_MISS_PAY_ELEMENT_INPUT_REC,
   x_loading_status     OUT NOCOPY   VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Uupdate_Pay_Element_Input';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_pay_element_input_rec     pay_element_input_rec_type := G_MISS_PAY_ELEMENT_INPUT_REC ;
      l_action         VARCHAR2(30) := 'UPDATE';

      l_column_name   cn_objects.name%TYPE;
      l_table_name    cn_objects.name%TYPE;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT	Update_pay_element_input;

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
   l_pay_element_input_rec := p_pay_element_input_rec;

   -- Trim spaces before/after user input string (New record) if missing,
   -- assign the old value into it

  SELECT
    Decode(p_pay_element_input_rec.pay_element_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_pay_element_input_rec.pay_element_name),
     Decode(p_pay_element_input_rec.table_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_pay_element_input_rec.table_name),
     Decode(p_pay_element_input_rec.column_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_pay_element_input_rec.column_name),
     Decode(p_pay_element_input_rec.pay_input_name,
	    FND_API.G_MISS_CHAR, NULL ,
	    p_pay_element_input_rec.pay_input_name),
     Decode(p_pay_element_input_rec.line_number,
            FND_API.G_MISS_NUM, NULL ,
	    p_pay_element_input_rec.line_number),
     Decode(p_pay_element_input_rec.pay_element_input_id,
            FND_API.G_MISS_NUM, NULL ,
	    p_pay_element_input_rec.pay_element_input_id),
     Decode(p_pay_element_input_rec.element_input_id,
            FND_API.G_MISS_NUM, NULL ,
	    p_pay_element_input_rec.element_input_id),
     Decode(p_pay_element_input_rec.element_type_id,
            FND_API.G_MISS_NUM, NULL ,
	    p_pay_element_input_rec.element_type_id),
     Decode(p_pay_element_input_rec.tab_object_id,
            FND_API.G_MISS_NUM, NULL ,
	    p_pay_element_input_rec.tab_object_id),
     Decode(p_pay_element_input_rec.col_object_id,
            FND_API.G_MISS_NUM, NULL ,
	    p_pay_element_input_rec.col_object_id),
     Decode(p_pay_element_input_rec.start_date,
            FND_API.G_MISS_DATE, NULL ,
	    p_pay_element_input_rec.start_date),
     Decode(p_pay_element_input_rec.end_date,
            FND_API.G_MISS_DATE, NULL ,
	    p_pay_element_input_rec.end_date),
     Decode(p_pay_element_input_rec.quota_pay_element_id,
            FND_API.G_MISS_NUM, NULL ,
	    p_pay_element_input_rec.quota_pay_element_id)
     INTO
      l_pay_element_input_rec.pay_element_name,
      l_pay_element_input_rec.table_name,
      l_pay_element_input_rec.column_name,
      l_pay_element_input_rec.pay_input_name,
      l_pay_element_input_rec.line_number,
      l_pay_element_input_rec.pay_element_input_id,
      l_pay_element_input_rec.element_input_id,
      l_pay_element_input_rec.element_type_id,
      l_pay_element_input_rec.tab_object_id,
      l_pay_element_input_rec.col_object_id,
      l_pay_element_input_rec.start_date,
      l_pay_element_input_rec.end_date,
      l_pay_element_input_rec.quota_pay_element_id
     FROM dual;


   get_object_id(l_pay_element_input_rec.table_name,
                   'TBL',
                    null,
                    l_table_name,
                    l_pay_element_input_rec.tab_object_id);


    -- get column
     get_object_id(l_pay_element_input_rec.column_name,
                   'COL',
                    l_pay_element_input_rec.tab_object_id,
                    l_column_name,
                    l_pay_element_input_rec.col_object_id );

    --
    -- Valid payment plan assignvnment
    --
    valid_pei_mapping
     ( x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_pay_element_input_rec => l_pay_element_input_rec,
       p_table_name            => l_table_name,
       p_column_name           => l_column_name,
       p_action                => l_action,
       p_loading_status        => x_loading_status,
       x_loading_status        => x_loading_status
       );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSE
      -- Update

    cn_pay_element_inputs_pkg.update_row
	(p_pay_element_input_id => l_pay_element_input_rec.pay_element_input_id
	,p_quota_pay_element_id	=> l_pay_element_input_rec.quota_pay_element_id
        ,p_element_input_id     => l_pay_element_input_rec.element_input_id
        ,p_element_type_id	=> l_pay_element_input_rec.element_type_id
        ,p_tab_object_id        => l_pay_element_input_rec.tab_object_id
        ,p_col_object_id        => l_pay_element_input_rec.col_object_id
        ,p_line_number	        => null -- not using
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
      ROLLBACK TO Update_pay_element_input;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_pay_element_input;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_pay_element_input;
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

END Update_pay_element_input;

--============================================================================
--| Procedure : Delete_pay_element_input
--|
--============================================================================
 PROCEDURE Delete_pay_element_input
  (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2 := CN_API.G_FALSE,
   p_commit	          IN  VARCHAR2 := CN_API.G_FALSE,
   p_validation_level     IN  NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count	          OUT NOCOPY NUMBER,
   x_msg_data	          OUT NOCOPY VARCHAR2,
   p_pay_element_input_id IN  NUMBER,
   x_loading_status       OUT NOCOPY VARCHAR2
) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Pay_Element_Input';
      l_api_version  CONSTANT NUMBER  := 1.0;


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT	Delete_Pay_Element_Input;
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

   -- Delete record
   cn_pay_element_inputs_pkg.delete_row
     (p_pay_element_input_id      =>p_pay_element_input_id);
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
      ROLLBACK TO Delete_pay_element_input;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Pay_Element_Input;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_pay_element_input;
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

END Delete_Pay_Element_Input;

--============================================================================
--| Procedure : Get_pay_element_input
--|
--============================================================================
   PROCEDURE  Get_pay_element_input
   ( p_api_version            IN   NUMBER,
     p_init_msg_list          IN   VARCHAR2,
     p_commit                 IN   VARCHAR2,
     p_validation_level       IN   NUMBER,
     x_return_status          OUT NOCOPY  VARCHAR2,
     x_msg_count              OUT NOCOPY  NUMBER,
     x_msg_data               OUT NOCOPY  VARCHAR2,
     p_element_type_id        IN   cn_pay_element_inputs.element_type_id%TYPE,
     p_start_record           IN   NUMBER,
     p_increment_count        IN   NUMBER,
     p_order_by               IN   VARCHAR2,
     x_pay_element_input_tbl  OUT NOCOPY  pay_element_input_out_tbl_type,
     x_total_records          OUT NOCOPY  NUMBER,
     x_status                 OUT NOCOPY  VARCHAR2,
     x_loading_status         OUT NOCOPY  VARCHAR2
     ) IS

    TYPE quotacurtype IS ref CURSOR;

    cur quotacurtype;


      l_api_name         CONSTANT VARCHAR2(30)  := 'Get_pay_element_input';
      l_api_version                CONSTANT NUMBER        := 1.0;

      l_counter NUMBER;

      l_pay_element_input_id    cn_pay_element_inputs.pay_element_input_id%TYPE;
      l_element_input_id        cn_pay_element_inputs.element_input_id%TYPE;
      l_element_type_id         cn_pay_element_inputs.element_type_id%TYPE;
      l_table_name	        cn_objects_all.name%TYPE;
      l_column_name             cn_objects_all.name%TYPE;
      l_pay_element_name        pay_element_types.element_name%TYPE;
      l_pay_input_name          pay_input_values_f.name%TYPE;
      l_line_number             cn_pay_element_inputs.line_number%TYPE;
      l_quota_pay_element_id 	cn_pay_element_inputs.quota_pay_element_id%TYPE;


 l_select Varchar2(32000):= ' SELECT cpei.pay_element_input_id pay_element_input_id ,     cpei.element_input_id element_input_id,
           cpei.element_type_id  element_type_id,
           ct.user_name table_name,
           cc.user_name column_name ,
           pet.element_name element_name ,
           piv.name pay_value_name,
           piv.display_sequence line_number,
           cpei.quota_pay_element_id quota_pay_element_id
     FROM cn_pay_element_inputs cpei,
          cn_quota_pay_elements cqpe,
          pay_input_values_f  piv,
          pay_element_types_f pet,
          cn_objects  ct,
          cn_objects  cc,
          gl_sets_of_books glsob,
          cn_repositories cnr
      where
          cnr.set_of_books_id       = glsob.set_of_books_id
       AND  pet.input_currency_code = glsob.currency_code
       AND  cpei.quota_pay_element_id = cqpe.quota_pay_element_id
       AND cqpe.pay_element_type_id = pet.element_type_id
       AND cqpe.start_date >= pet.effective_start_date
       AND cqpe.end_date   <= pet.effective_end_date
       AND trunc(pet.effective_start_date) = trunc(piv.effective_start_date)
       AND trunc(pet.effective_end_date) = trunc(piv.effective_end_date)
       AND pet.element_type_id =  piv.element_type_id
       AND cpei.element_input_id = piv.input_value_id
       AND cpei.tab_object_id    = ct.object_id
       AND cpei.col_object_id    = cc.object_id
       AND cqpe.quota_pay_element_id = :B1
      UNION
      SELECT 0 pay_element_input_id ,
           piv.input_value_id element_input_id,
           piv.element_type_id element_type_id,
           NULL table_name,
           NULL column_name ,
           pet.element_name,
           piv.name pay_value_name,
           piv.display_sequence  line_number,
           0  quota_pay_element_id
      FROM
          pay_input_values_f  piv,
          pay_element_types_f pet,
          cn_quota_pay_elements cqpe,
          gl_sets_of_books glsob,
          cn_repositories cnr
      where
           cnr.set_of_books_id     = glsob.set_of_books_id
       AND pet.input_currency_code = glsob.currency_code
       AND cqpe.quota_pay_element_id = :B2
       AND cqpe.pay_element_type_id = pet.element_type_id
       AND cqpe.start_date >= pet.effective_start_date
       AND cqpe.end_date   <= pet.effective_end_date
       AND trunc(pet.effective_start_date) = trunc(piv.effective_start_date)
       AND trunc(pet.effective_end_date) = trunc(piv.effective_end_date)
       AND pet.element_type_id =  piv.element_type_id
       AND  not exists ( select 1 from cn_pay_element_inputs cpei
                          WHERE  cpei.quota_pay_element_id = cqpe.quota_pay_element_id
                           AND cqpe.pay_element_type_id = piv.element_type_id
                           AND  cpei.element_input_id = piv.input_value_id )
    ORDER BY line_number, element_input_id ';

  BEGIN

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

 OPEN cur FOR l_select using p_element_type_id, p_element_type_id;
   LOOP

     FETCH cur INTO
      l_pay_element_input_id
      ,l_element_input_id
      ,l_element_type_id
      ,l_table_name
      ,l_column_name
      ,l_pay_element_name
      ,l_pay_input_name
      ,l_line_number
      ,l_quota_pay_element_id;

     EXIT WHEN cur%notfound;
     x_total_records := x_total_records + 1;

     IF (l_counter + 1 BETWEEN p_start_record
         AND (p_start_record + p_increment_count - 1))
       THEN
         x_pay_element_input_tbl(l_counter).pay_element_input_id
         := l_pay_element_input_id;

         x_pay_element_input_tbl(l_counter).element_input_id
         := l_element_input_id;

         x_pay_element_input_tbl(l_counter).element_type_id
         := l_element_type_id;


         x_pay_element_input_tbl(l_counter).table_name
         := l_table_name;

         x_pay_element_input_tbl(l_counter).column_name
         := l_column_name;

         x_pay_element_input_tbl(l_counter).pay_element_name
         := l_pay_element_name;

         x_pay_element_input_tbl(l_counter).pay_input_name
         := l_pay_input_name;

         x_pay_element_input_tbl(l_counter).line_number
        := l_line_number;

         x_pay_element_input_tbl(l_counter).quota_pay_element_id
        := l_quota_pay_element_id;

     END IF;

     l_counter := l_counter + 1;

     END LOOP;
     CLOSE cur;

     x_loading_status := 'SELECTED';

     -- End of API body.

 FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data   ,
      p_encoded => FND_API.G_FALSE
      );
      WHEN OTHERS THEN

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
END  Get_pay_element_input;

END CN_PAY_ELEMENT_INPUTS_PVT ;

/
