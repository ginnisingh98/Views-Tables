--------------------------------------------------------
--  DDL for Package Body CN_RT_QUOTA_ASGNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RT_QUOTA_ASGNS_PVT" as
/* $Header: cnxvrqab.pls 120.2 2007/08/10 20:35:41 rnagired ship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_RT_QUOTA_ASGNS_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnxvrqab.pls';
G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
G_ROWID                     VARCHAR2(30);
G_PROGRAM_TYPE              VARCHAR2(30);
--|------------------------------------------------------------------------+
--|  Procedure Name : Validate_Rt_quota_Asgns
--| Description: Validate the Rate Quota Informations like
--| Start Date is mandatory, Rate schedule Name is mandatory ,
--| End Date must be greater than start date
--| Start Date and end must be within the range of quota start date
--| and end date
--|------------------------------------------------------------------------+
PROCEDURE Validate_rt_Quota_asgns
  (
   x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2 ,
   p_rt_quota_asgns_rec     IN  cn_plan_element_pub.rt_quota_asgns_rec_type,
   x_rate_schedule_id       OUT NOCOPY NUMBER,
   x_rt_quota_asgn_id       OUT NOCOPY NUMBER,
   x_calc_formula_id        OUT NOCOPY NUMBER,
   p_quota_id               IN  NUMBER,
   p_quota_name             IN cn_quotas.name%TYPE,
   p_org_id									IN NUMBER,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   )
  IS

-- Cursor
--     CURSOR rt_quota_asgns_seq_curs(l_quota_id NUMBER) IS
--	SELECT end_date,
--               quota_id
--	  FROM cn_rt_quota_asgns
--	  WHERE quota_id = l_quota_id
--	  ORDER BY start_date DESC ;

     l_tmp		NUMBER;
     l_api_name	        CONSTANT VARCHAR2(30) := 'Validate_Rt_Quota_Asgns';
     l_lkup_meaning     cn_lookups.meaning%TYPE;
     l_calc_formula_id  cn_calc_formulas.calc_formula_id%TYPE;
     l_loading_status   VARCHAR2(80);

BEGIN
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;


   -- Check Rate Schedule Name is not null

   l_lkup_meaning := cn_api.get_lkup_meaning('RATE_SCHEDULE_NAME','PE_OBJECT_TYPE');
   IF ( (cn_api.chk_null_char_para
	 (p_char_para => p_rt_quota_asgns_rec.rate_schedule_name,
	  p_obj_name  => l_lkup_meaning,
	  p_loading_status => x_loading_status,
	  x_loading_status => l_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- Check Start Date is not null

   l_lkup_meaning := cn_api.get_lkup_meaning('RATE_START_DATE','PE_OBJECT_TYPE');
   IF ( (cn_api.chk_null_char_para
	 (p_char_para => p_rt_quota_asgns_rec.start_date,
	  p_obj_name  => l_lkup_meaning,
	  p_loading_status => x_loading_status,
	  x_loading_status => l_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- get rate Schedule ID, raise an error if rate schedule id not found.

   x_rate_schedule_id
     := cn_api.get_rate_table_id(p_rt_quota_asgns_rec.rate_schedule_name,p_rt_quota_asgns_rec.org_id);

   l_calc_formula_id
     := cn_chk_plan_element_pkg.get_calc_formula_id(
                    p_rt_quota_asgns_rec.calc_formula_name,p_org_id);
   x_calc_formula_id := l_calc_formula_id;

   -- Raise an error, if rate schedule id is null, not exists in the database
   IF x_rate_schedule_id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_RATE_SCH_NOT_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'RATE_SCH_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- Validate Rule : End period must be greater than Start period

   IF (p_rt_quota_asgns_rec.end_date IS NOT NULL
       AND trunc(p_rt_quota_asgns_rec.end_date) <  Trunc(p_rt_quota_asgns_rec.start_date)) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATE_RANGE');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'INVALID_END_DATE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- get the rt_quota Asgns ID if any one of the old value is not null
   -- for Update only
   -- clku, 8/27/2001, If condition enhanced to fix bug 1951983
   IF ( (p_rt_quota_asgns_rec.start_date_old IS NOT NULL AND
         p_rt_quota_asgns_rec.start_date_old <> cn_api.g_miss_date) OR
	    (p_rt_quota_asgns_rec.end_date_old   IS NOT NULL AND
         p_rt_quota_asgns_rec.end_date_old   <> cn_api.g_miss_date) OR
 	    (p_rt_quota_asgns_rec.rate_schedule_name_old IS NOT NULL AND
         p_rt_quota_asgns_rec.rate_schedule_name_old <> cn_api.g_miss_char)) THEN

      -- Get the rt_quota_asgn_id to Update the exact record.

      x_rt_quota_asgn_id := cn_chk_plan_element_pkg.get_rt_quota_asgn_id
	(p_quota_id         => p_quota_id,
         p_rate_schedule_id => cn_api.get_rate_table_id
	                       (p_rt_quota_asgns_rec.rate_schedule_name_old,p_rt_quota_asgns_rec.org_id),
         p_calc_formula_id  => l_calc_formula_id,
	 p_start_date       => p_rt_quota_asgns_rec.start_date_old,
	 p_end_date         => p_rt_quota_asgns_rec.end_date_old
	 );


      -- check the rt_quota_asgns_id is Not null and exists in the database

      IF x_rt_quota_asgn_id IS NULL THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_RT_QUOTA_NOT_EXISTS');
	    FND_MESSAGE.SET_TOKEN('QUOTA_NAME',p_quota_name);
	    FND_MESSAGE.SET_TOKEN('RATE_SCHEDULE_NAME',p_rt_quota_asgns_rec.rate_schedule_name_old );
	    FND_MESSAGE.SET_TOKEN('START_DATE',p_rt_quota_asgns_rec.start_date_old );
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'RT_QUOTA_NOT_EXISTS';
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;


   -- Check Duplicate or invalid Sequence Date only

   SELECT COUNT(*)
	INTO l_tmp
	FROM cn_rt_Quota_asgns
	WHERE quota_id           = p_quota_id
        AND calc_formula_id      = l_calc_formula_id
        AND  rt_quota_asgn_id   <> Nvl(x_rt_quota_asgn_id,0)
	AND Trunc(start_date)    = Trunc(p_rt_quota_Asgns_rec.start_date)
     ;
	      IF (l_tmp <> 0) THEN
		 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
		    FND_MESSAGE.SET_NAME ('CN' , 'CN_RT_QUOTA_EXISTS');
		    FND_MSG_PUB.Add;
		 END IF;
		 x_loading_status := 'RT_QUOTA_EXISTS';
	      END IF ;

   -- Check date Effetcivity, quota rate assigns start date and end must
   -- be with start date and end date of the quota date

   cn_chk_plan_element_pkg.chk_date_effective
     (
      x_return_status         => x_return_status,
      p_start_date            => p_rt_quota_asgns_rec.start_date,
      p_end_date              => p_rt_quota_asgns_rec.end_date,
      p_quota_id              => p_quota_id,
      p_object_type           => 'RATE',
      p_loading_status        => x_loading_status,
      x_loading_status        => l_loading_status );

      x_loading_status := l_loading_status;

   -- check quota type, if quota type is NONE you cannot have rates

   IF Nvl(cn_chk_plan_element_pkg.get_quota_type ( p_quota_id ),'NONE') = 'NONE' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_QUOTA_CANNOT_HAVE_RATE' );
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'QUOTA_CANNOT_HAVE_RATE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- End of Validate rt Quota Asigns .
   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
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
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  =>  x_msg_count,
         p_data   =>  x_msg_data,
         p_encoded=> FND_API.G_FALSE
	 );

END Validate_rt_quota_asgns;
 --|-----------------------------------------------------------------------+
 --|  Procedure Name : Create rt Quota Asgns
 --|
 --|-----------------------------------------------------------------------+
PROCEDURE Create_rt_quota_asgns
  (
   p_api_version        IN	NUMBER,
   p_init_msg_list	    IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	    	      IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level	  IN  NUMBER	 :=  FND_API.G_VALID_LEVEL_FULL,
   x_return_status	    OUT NOCOPY VARCHAR2,
   x_msg_count		      OUT NOCOPY NUMBER,
   x_msg_data		        OUT NOCOPY VARCHAR2,
   p_quota_name         IN  cn_quotas.name%TYPE,
   p_org_id             IN NUMBER,
   p_rt_quota_asgns_rec_tbl IN  cn_plan_element_pub.rt_quota_asgns_rec_tbl_type
                            :=  cn_plan_element_pub.g_miss_rt_quota_asgns_rec_tbl,
   x_loading_status	    OUT NOCOPY VARCHAR2,
   x_object_version_number IN OUT NOCOPY NUMBER
   ) IS

      l_api_name		CONSTANT VARCHAR2(30)
	                        := 'Create_Rt_Quota_Asgns';
      l_api_version           	CONSTANT NUMBER := 1.0;
      l_rt_quota_asgn_id       NUMBER;
      l_quota_id               NUMBER;
      l_rate_schedule_id       NUMBER;
      l_tmp                    NUMBER;
      l_rate_date_seq_rec_tbl  rate_date_seq_rec_tbl_type;
      l_calc_formula_id        NUMBER;
      l_loading_status   VARCHAR2(80);

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT    create_rt_quota_asgns ;


   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
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
   x_loading_status := 'CN_INSERTED';


   -- API body
   -- Validate the Rt quota Assgns

   IF p_rt_quota_asgns_rec_tbl.COUNT > 0 THEN

      -- check quota name is missing or null, mandatory
      IF ( (cn_api.chk_miss_char_para
	    ( p_char_para => p_quota_name,
	      p_para_name => CN_CHK_PLAN_ELEMENT_PKG.G_PE_NAME,
	      p_loading_status => x_loading_status,
	      x_loading_status => l_loading_status)) = FND_API.G_TRUE) THEN
	 RAISE FND_API.G_EXC_ERROR ;
       ELSIF ( (cn_api.chk_null_char_para
		(p_char_para => p_quota_name,
		 p_obj_name  => CN_CHK_PLAN_ELEMENT_PKG.G_PE_NAME,
		 p_loading_status => x_loading_status,
		 x_loading_status => l_loading_status)) = FND_API.G_TRUE ) THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;


      -- get Quota ID

      l_quota_id  := cn_chk_plan_element_pkg.get_quota_id(p_quota_name,p_org_id);


      -- if Quota id is null and name is not null then raise an error

      IF (p_quota_name IS NOT NULL
	  AND l_quota_id IS NULL )
	    THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
	       FND_MESSAGE.SET_NAME('CN' , 'CN_PLN_NOT_EXIST');
	       FND_MESSAGE.SET_TOKEN('PE_NAME',p_quota_name);
	       FND_MSG_PUB.Add;
	    END IF;
	    x_loading_status := 'CN_PLN_NOT_EXIST' ;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;


      -- loop through if more than one record in the PL/SQL table

      l_tmp := p_rt_quota_asgns_rec_tbl.COUNT;

    --  FOR I IN 1..p_rt_quota_asgns_rec_tbl.COUNT
    --	LOOP
    FOR I IN p_rt_quota_asgns_rec_tbl.FIRST..p_rt_quota_asgns_rec_tbl.LAST LOOP

	   -- Validate the Quota Rate Assigns

	   Validate_rt_quota_asgns
	     (
	      x_return_status      => x_return_status,
	      x_msg_count          => x_msg_count,
	      x_msg_data           => x_msg_data,
	      p_rt_quota_asgns_rec => p_rt_quota_asgns_rec_tbl(i),
	      p_quota_name         => p_quota_name,
				p_org_id		         => p_org_id,
	      p_quota_id           => l_quota_id,
	      x_rate_schedule_id   => l_rate_schedule_id,
	      x_rt_quota_asgn_id   => l_rt_quota_asgn_id,
              x_calc_formula_id    => l_calc_formula_id,
	      p_loading_status     => x_loading_status,
	      x_loading_status     => l_loading_status
	      );

	      x_loading_status := l_loading_status;
	   -- Check the Return Status and Loading Status

	   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      RAISE FND_API.G_EXC_ERROR ;
	    ELSIF ( x_return_status   = FND_API.G_RET_STS_SUCCESS )
	      AND ( x_loading_status  <>  'RT_QUOTA_EXISTS' )
	      THEN

	      -- Insert the Rt_quota assigns record.


	      CN_RT_QUOTA_ASGNS_PKG.begin_record
		(x_org_id		         => p_org_id,
		 x_Operation            => 'INSERT'
		 ,x_Rowid                 => G_ROWID
		 ,x_rt_quota_asgn_id      => l_rt_quota_asgn_id
                 ,x_calc_formula_id       => l_calc_formula_id
		 ,x_quota_id              => l_quota_id
		 ,x_start_date            => p_rt_quota_asgns_rec_tbl(i).start_date
		 ,x_end_date              => p_rt_quota_asgns_rec_tbl(i).end_date
		 ,x_rate_schedule_id      => l_rate_schedule_id
		 ,x_attribute_category    => p_rt_quota_asgns_rec_tbl(i).attribute_category
		 ,x_attribute1            => p_rt_quota_asgns_rec_tbl(i).attribute1
		 ,x_attribute2            => p_rt_quota_asgns_rec_tbl(i).attribute2
		 ,x_attribute3            => p_rt_quota_asgns_rec_tbl(i).attribute3
		 ,x_attribute4            => p_rt_quota_asgns_rec_tbl(i).attribute4
		 ,x_attribute5            => p_rt_quota_asgns_rec_tbl(i).attribute5
		 ,x_attribute6            => p_rt_quota_asgns_rec_tbl(i).attribute6
		 ,x_attribute7            => p_rt_quota_asgns_rec_tbl(i).attribute7
		 ,x_attribute8            => p_rt_quota_asgns_rec_tbl(i).attribute8
		,x_attribute9            => p_rt_quota_asgns_rec_tbl(i).attribute9
		,x_attribute10           => p_rt_quota_asgns_rec_tbl(i).attribute10
		,x_attribute11           => p_rt_quota_asgns_rec_tbl(i).attribute11
		,x_attribute12           => p_rt_quota_asgns_rec_tbl(i).attribute12
		,x_attribute13           => p_rt_quota_asgns_rec_tbl(i).attribute13
		,x_attribute14           => p_rt_quota_asgns_rec_tbl(i).attribute14
		,x_attribute15           => p_rt_quota_asgns_rec_tbl(i).attribute15
		,x_last_update_date      => G_LAST_UPDATE_DATE
		,x_last_updated_by       => G_LAST_UPDATED_BY
		,x_creation_date         => G_CREATION_DATE
		,x_created_by            => G_CREATED_BY
		,x_last_update_login     => G_LAST_UPDATE_LOGIN
		,x_Program_type          => G_program_type,
		 x_object_version_number => x_object_version_number ) ;

	      l_rate_date_seq_rec_tbl(i).start_date :=  p_rt_quota_asgns_rec_tbl(i).start_date;
	      l_rate_date_seq_rec_tbl(i).start_date_old :=
		                                    p_rt_quota_asgns_rec_tbl(i).start_date_old;
              l_rate_date_seq_rec_tbl(i).end_date :=  p_rt_quota_asgns_rec_tbl(i).end_date ;
              l_rate_date_seq_rec_tbl(i).end_date_old :=p_rt_quota_asgns_rec_tbl(i).end_date_old;

	      l_rate_date_seq_rec_tbl(i).quota_id := l_quota_id;

	      l_rate_date_seq_rec_tbl(i).rt_quota_asgn_id := l_rt_quota_asgn_id ;



	    ELSIF   x_loading_status = 'RT_QUOTA_EXISTS' THEN
	      RAISE FND_API.G_EXC_ERROR ;
	   END IF ;
	END LOOP;

	-- We need to check one level After than

	-- Check the Sequence, are there any records exists before this
	-- record, if exists it should be


	--FOR I IN 1..l_rate_date_seq_rec_tbl.COUNT
	  --LOOP
	  FOR I IN l_rate_date_seq_rec_tbl.FIRST..l_rate_date_seq_rec_tbl.LAST LOOP
	     IF (( Trunc(l_rate_date_seq_rec_tbl(i).start_date_old)
		   <> Trunc(l_rate_date_seq_rec_tbl(i).start_date) OR
		   Nvl(Trunc(l_rate_date_seq_rec_tbl(i).end_date_old),fnd_api.g_miss_date) <>
		   Nvl(Trunc(l_rate_date_seq_rec_tbl(i).end_date),fnd_api.g_miss_date)))
	       THEN


		-- Check the sequence and overlap of the start date and the end date

		cn_chk_plan_element_pkg.chk_rate_quota_iud
		  (
		   x_return_status      => x_return_status,
		   p_start_Date         => l_rate_date_seq_rec_tbl(i).start_date,
		   p_end_date           => l_rate_date_seq_rec_tbl(i).end_date,
		   p_iud_flag           => 'U',
		   p_quota_id           => l_rate_date_seq_rec_tbl(i).quota_id,
                   p_calc_formula_id    => l_calc_formula_id,
		   p_rt_quota_asgn_id   => l_rate_date_seq_rec_tbl(i).rt_quota_asgn_id,
		   p_loading_status     => x_loading_status,
		   x_loading_status     => l_loading_status
		   );

		x_loading_status := l_loading_status;
		-- Raise an error if the return status is not success

		IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		     THEN
		      FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATE_SEQUENCE' );
		      FND_MSG_PUB.Add;
		   END IF;
		   x_loading_status := 'CN_INVALID_DATE_SEQUENCE';
		   RAISE FND_API.G_EXC_ERROR ;
		END IF;
	     END IF;

	  END LOOP;
   END IF;
   -- End of API body.
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
      ROLLBACK TO create_rt_quota_asgns;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_rt_quota_asgns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO create_rt_quota_asgns;
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

END Create_rt_quota_Asgns;
--|-------------------------------------------------------------------------+
--|  Procedure Name : Update rt Quota Asgns
--|
--|-------------------------------------------------------------------------+
PROCEDURE  Update_rt_quota_asgns
  (
   p_api_version	    IN   NUMBER,
   p_init_msg_list	    IN   VARCHAR2 := FND_API.G_FALSE,
   p_commit	    	    IN   VARCHAR2 := FND_API.G_FALSE,
   p_validation_level	    IN   NUMBER	:=
                                 FND_API.G_VALID_LEVEL_FULL,
   x_return_status          OUT NOCOPY  VARCHAR2,
   x_msg_count	            OUT NOCOPY  NUMBER,
   x_msg_data		    OUT NOCOPY  VARCHAR2,
   p_quota_name             IN   cn_quotas.name%TYPE,
   p_org_id             IN NUMBER,
   p_rt_quota_asgns_rec_tbl IN   cn_plan_element_pub.rt_quota_asgns_rec_tbl_type
                                 := cn_plan_element_pub.g_miss_rt_quota_asgns_rec_tbl,
   x_loading_status    	    OUT NOCOPY  VARCHAR2,
   x_object_version_number IN OUT NOCOPY NUMBER
   ) IS

      l_api_name		CONSTANT VARCHAR2(30)
	                        := 'Update_Rt_Quota_Asgns';
      l_api_version             CONSTANT NUMBER := 1.0;
      l_rt_quota_asgn_id        NUMBER;
      l_quota_id                NUMBER;
      l_rate_schedule_id        NUMBER;
      l_calc_formula_id         NUMBER;
      l_rate_date_seq_rec_tbl  rate_date_seq_rec_tbl_type;
      l_loading_status   VARCHAR2(80);

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT    Update_Plan_element ;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
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
   x_loading_status := 'CN_UPDATED';


   -- API body
   -- Validate the Rate Quota assigns

   IF p_rt_quota_asgns_rec_tbl.COUNT > 0 THEN

    -- check quota name is missing or null, mandatory
       IF ( (cn_api.chk_miss_char_para
	     ( p_char_para => p_quota_name,
	       p_para_name => CN_CHK_PLAN_ELEMENT_PKG.G_PE_NAME,
	       p_loading_status => x_loading_status,
	       x_loading_status => l_loading_status)) = FND_API.G_TRUE) THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF ( (cn_api.chk_null_char_para
		 (p_char_para => p_quota_name,
		  p_obj_name  => CN_CHK_PLAN_ELEMENT_PKG.G_PE_NAME,
		  p_loading_status => x_loading_status,
		  x_loading_status => l_loading_status)) = FND_API.G_TRUE ) THEN
	  RAISE FND_API.G_EXC_ERROR ;
       END IF;

       l_quota_id  := cn_chk_plan_element_pkg.get_quota_id(p_quota_name,p_org_id);

       -- get Quota id, if id is null and name is not null then raise an error

       IF (p_quota_name IS NOT NULL
	   AND l_quota_id IS NULL )
	     THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	    THEN
	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	       THEN
		FND_MESSAGE.SET_NAME('CN' , 'CN_PLN_NOT_EXIST');
		FND_MESSAGE.SET_TOKEN('PE_NAME',p_quota_name);
		FND_MSG_PUB.Add;
	     END IF;
	     x_loading_status := 'CN_PLN_NOT_EXIST' ;
	     RAISE FND_API.G_EXC_ERROR ;
	  END IF;
       END IF;


       -- loop through if more than one record in the PL/SQL table

      FOR i IN 1..p_rt_quota_asgns_rec_tbl.COUNT LOOP

	 -- Validate the new record and get the old id for update
	 Validate_rt_quota_asgns
	   (
	    x_return_status      => x_return_status,
	    x_msg_count          => x_msg_count,
	    x_msg_data           => x_msg_data,
	    p_rt_quota_asgns_rec => p_rt_quota_asgns_rec_tbl(i),
	    p_quota_name         => p_quota_name,
			p_org_id						 => p_org_id,
	    p_quota_id           => l_quota_id,
	    x_rate_schedule_id   => l_rate_schedule_id,
	    x_rt_quota_asgn_id   => l_rt_quota_asgn_id,
            x_calc_formula_id    => l_calc_formula_id,
	    p_loading_status     => x_loading_status,
	    x_loading_status     => l_loading_status
	    );
     x_loading_status := l_loading_status;

	 -- Check the Return Status and the Loading Status

	 IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF ( x_return_status   = FND_API.G_RET_STS_SUCCESS )
	    AND ( x_loading_status  =  'CN_UPDATED' )
	    THEN
            -- Update Rt Quota Assigns
	    CN_RT_QUOTA_ASGNS_PKG.begin_record
	      (x_org_id		         => p_org_id,
	       x_Operation            => 'UPDATE'
	       ,x_Rowid                 => G_ROWID
	       ,x_rt_quota_asgn_id      => l_rt_quota_asgn_id
               ,x_calc_formula_id       => l_calc_formula_id
	       ,x_quota_id              => l_quota_id
	       ,x_start_date            => p_rt_quota_asgns_rec_tbl(i).start_date
	       ,x_end_date              => p_rt_quota_asgns_rec_tbl(i).end_date
	       ,x_rate_schedule_id      => l_rate_schedule_id
	       ,x_attribute_category    => p_rt_quota_asgns_rec_tbl(i).attribute_category
	       ,x_attribute1            => p_rt_quota_asgns_rec_tbl(i).attribute1
	       ,x_attribute2            => p_rt_quota_asgns_rec_tbl(i).attribute2
	       ,x_attribute3            => p_rt_quota_asgns_rec_tbl(i).attribute3
	       ,x_attribute4            => p_rt_quota_asgns_rec_tbl(i).attribute4
	       ,x_attribute5            => p_rt_quota_asgns_rec_tbl(i).attribute5
	       ,x_attribute6            => p_rt_quota_asgns_rec_tbl(i).attribute6
	       ,x_attribute7            => p_rt_quota_asgns_rec_tbl(i).attribute7
	       ,x_attribute8            => p_rt_quota_asgns_rec_tbl(i).attribute8
	      ,x_attribute9            => p_rt_quota_asgns_rec_tbl(i).attribute9
	      ,x_attribute10           => p_rt_quota_asgns_rec_tbl(i).attribute10
	      ,x_attribute11           => p_rt_quota_asgns_rec_tbl(i).attribute11
	      ,x_attribute12           => p_rt_quota_asgns_rec_tbl(i).attribute12
	      ,x_attribute13           => p_rt_quota_asgns_rec_tbl(i).attribute13
	      ,x_attribute14           => p_rt_quota_asgns_rec_tbl(i).attribute14
	      ,x_attribute15           => p_rt_quota_asgns_rec_tbl(i).attribute15
	      ,x_last_update_date      => G_LAST_UPDATE_DATE
	      ,x_last_updated_by       => G_LAST_UPDATED_BY
	      ,x_creation_date         => G_CREATION_DATE
	      ,x_created_by            => G_CREATED_BY
	      ,x_last_update_login     => G_LAST_UPDATE_LOGIN
	      ,x_Program_type          => G_program_type,
		 x_object_version_number => x_object_version_number ) ;

	        l_rate_date_seq_rec_tbl(i).start_date :=  p_rt_quota_asgns_rec_tbl(i).start_date;
	      l_rate_date_seq_rec_tbl(i).start_date_old :=
		                                    p_rt_quota_asgns_rec_tbl(i).start_date_old;
              l_rate_date_seq_rec_tbl(i).end_date :=  p_rt_quota_asgns_rec_tbl(i).end_date ;
              l_rate_date_seq_rec_tbl(i).end_date_old :=p_rt_quota_asgns_rec_tbl(i).end_date_old;

	      l_rate_date_seq_rec_tbl(i).quota_id := l_quota_id;

	      l_rate_date_seq_rec_tbl(i).rt_quota_asgn_id := l_rt_quota_asgn_id ;

	  ELSIF   x_loading_status = 'RT_QUOTA_EXISTS' THEN
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF ;
      END LOOP;

      	-- We need to check one level After than

	-- Check the Sequence, are there any records exists before this
	-- record, if exists it should be


	FOR I IN 1..l_rate_date_seq_rec_tbl.COUNT
	  LOOP

	     IF (( Trunc(l_rate_date_seq_rec_tbl(i).start_date_old)
		   <> Trunc(l_rate_date_seq_rec_tbl(i).start_date) OR
		   Nvl(Trunc(l_rate_date_seq_rec_tbl(i).end_date_old),fnd_api.g_miss_date) <>
		   Nvl(Trunc(l_rate_date_seq_rec_tbl(i).end_date),fnd_api.g_miss_date)))
	       THEN


		-- Check the sequence and overlap of the start date and the end date

		cn_chk_plan_element_pkg.chk_rate_quota_iud
		  (
		   x_return_status      => x_return_status,
		   p_start_Date         => l_rate_date_seq_rec_tbl(i).start_date,
		   p_end_date           => l_rate_date_seq_rec_tbl(i).end_date,
		   p_iud_flag           => 'U',
		   p_quota_id           => l_rate_date_seq_rec_tbl(i).quota_id,
                   p_calc_formula_id    => l_calc_formula_id,
		   p_rt_quota_asgn_id   => l_rate_date_seq_rec_tbl(i).rt_quota_asgn_id,
		   p_loading_status     => x_loading_status,
		   x_loading_status     => l_loading_status
		   );
         x_loading_status := l_loading_status;


		-- Raise an error if the return status is not success

		IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		     THEN
		      FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATE_SEQUENCE' );
		      FND_MSG_PUB.Add;
		   END IF;
		   x_loading_status := 'CN_INVALID_DATE_SEQUENCE';
		   RAISE FND_API.G_EXC_ERROR ;
		END IF;
	     END IF;

	  END LOOP;
   END IF;
   -- End of Update API body.
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
      ROLLBACK TO update_Plan_element;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_Plan_Element;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO update_plan_element;
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
END Update_rt_quota_Asgns;
--|-------------------------------------------------------------------------+
--|  Procedure Name : Delete rt Quota Asgns
--|  Desc: Delete the Rate Quota assgns
--|-------------------------------------------------------------------------+
PROCEDURE  Delete_rt_quota_asgns
  (
   p_api_version	    IN 	NUMBER,
   p_init_msg_list	    IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	    	    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level	    IN  NUMBER	 :=
                            FND_API.G_VALID_LEVEL_FULL,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count	            OUT NOCOPY NUMBER,
   x_msg_data		    OUT NOCOPY VARCHAR2,
   p_quota_name             IN cn_quotas.name%TYPE,
   p_org_id				IN NUMBER,
   p_rt_quota_asgns_rec_tbl IN cn_plan_element_pub.rt_quota_asgns_rec_tbl_type
                            := cn_plan_element_pub.g_miss_rt_quota_asgns_rec_tbl,
   x_loading_status    	    OUT NOCOPY 	VARCHAR2

   ) IS

      l_api_name		CONSTANT VARCHAR2(30)
	                        := 'Delete_Rt_Quota_Asgns';
      l_api_version             CONSTANT NUMBER := 1.0;

      l_rt_quota_asgn_id        NUMBER;
      l_quota_id                NUMBER;
      l_loading_status   VARCHAR2(80);
			l_object_version_number  NUMBER;
BEGIN
   -- Delete RT_QUOTA_ASGNS API, Currently called from Forms Only

   -- Standard Start of API savepoint

   SAVEPOINT    Delete_Rt_Quota_Asgns ;
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

   -- Initialize message list if p_init_msg_list is set to TRUE.

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   -- API body
   -- Validate the Rate Quota assigns

   --
   -- get the Rt quota Asign ID to Delete the exact record.

   IF p_rt_quota_asgns_rec_tbl.COUNT > 0 THEN

      -- check quota name is missing or null, mandatory

      IF ( (cn_api.chk_miss_char_para
	    ( p_char_para => p_quota_name,
	      p_para_name => CN_CHK_PLAN_ELEMENT_PKG.G_PE_NAME,
	      p_loading_status => x_loading_status,
	      x_loading_status => l_loading_status)) = FND_API.G_TRUE) THEN
	 RAISE FND_API.G_EXC_ERROR ;
       ELSIF ( (cn_api.chk_null_char_para
		(p_char_para => p_quota_name,
		 p_obj_name  => CN_CHK_PLAN_ELEMENT_PKG.G_PE_NAME,
		 p_loading_status => x_loading_status,
		 x_loading_status => l_loading_status)) = FND_API.G_TRUE ) THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;

      l_quota_id  := cn_chk_plan_element_pkg.get_quota_id(p_quota_name,p_org_id);

      -- get Quota id, if id is null and name is not null then raise an error

      IF (p_quota_name IS NOT NULL
	  AND l_quota_id IS NULL )
	    THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
	       FND_MESSAGE.SET_NAME('CN' , 'CN_PLN_NOT_EXIST');
	       FND_MESSAGE.SET_TOKEN('PE_NAME',p_quota_name);
	       FND_MSG_PUB.Add;
	    END IF;
	    x_loading_status := 'CN_PLN_NOT_EXIST' ;
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
      END IF;


      FOR i IN 1..p_rt_quota_asgns_rec_tbl.COUNT
	LOOP

	   -- get rt quota Assign ID to delete the record

	   l_rt_quota_asgn_id := cn_chk_plan_element_pkg.get_rt_quota_asgn_id
	     (
	      p_quota_id   => l_quota_id,
              p_rate_schedule_id =>  cn_api.get_rate_table_id(
                                     p_rt_quota_asgns_rec_tbl(i).rate_schedule_name,p_rt_quota_asgns_rec_tbl(i).org_id),
              p_calc_formula_id => cn_chk_plan_element_pkg.get_calc_formula_id(
                                   p_rt_quota_asgns_rec_tbl(i).calc_formula_name,p_org_id),
	      p_start_date => p_rt_quota_asgns_rec_tbl(i).start_date,
	      p_end_date   => p_rt_quota_asgns_rec_tbl(i).end_date
	      );

	   -- if rate_quota_assign_id is NULL then Unable to find the record from database

	   IF l_rt_quota_asgn_id IS NULL THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
		 FND_MESSAGE.SET_NAME ('CN' , 'CN_RT_QUOTA_NOT_EXISTS');
		 FND_MESSAGE.SET_TOKEN('QUOTA_NAME',p_quota_name);
		 FND_MESSAGE.SET_TOKEN('RATE_SCHEDULE_NAME',p_rt_quota_asgns_rec_tbl(i).rate_schedule_name );
		 FND_MESSAGE.SET_TOKEN('START_DATE',p_rt_quota_asgns_rec_tbl(i).start_date );
		 FND_MSG_PUB.Add;
	      END IF;
	      x_loading_status := 'RT_QUOTA_NOT_EXISTS';
	      RAISE FND_API.G_EXC_ERROR ;
	   END IF;

	   -- Check wheather delete is Allowed, this only first and last record can be deleted

	   cn_chk_plan_element_pkg.chk_rate_quota_iud
	     (
	      x_return_status      => x_return_status,
	      p_start_Date         => p_rt_quota_asgns_rec_tbl(i).start_date,
	      p_end_date           => p_rt_quota_asgns_rec_tbl(i).end_date,
	      p_iud_flag           => 'D',
	      p_quota_id           => l_quota_id,
              p_calc_formula_id => cn_chk_plan_element_pkg.get_calc_formula_id(
                                   p_rt_quota_asgns_rec_tbl(i).calc_formula_name,p_org_id),
              p_rt_quota_asgn_id   => l_rt_quota_asgn_id,
	      p_loading_status     => x_loading_status,
	      x_loading_status     => l_loading_status
	      );
       x_loading_status := l_loading_status;

	   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
		 FND_MESSAGE.SET_NAME ('CN' , 'CN_RATE_DELETE_NOT_ALLOWED' );
		 FND_MSG_PUB.Add;
	      END IF;
	      x_loading_status := 'CN_RATE_DELETE_NOT_ALLOWED';
	      RAISE FND_API.G_EXC_ERROR ;
	   END IF;

	   -- If the the status is success and the lasding status is CN_DELETED then
	   -- delete the record.
	   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      RAISE FND_API.G_EXC_ERROR ;
	    ELSIF ( x_return_status   = FND_API.G_RET_STS_SUCCESS )
	      AND ( x_loading_status  =  'CN_DELETED' )
	      THEN
              -- Delete RT quota Assigns
	      CN_RT_QUOTA_ASGNS_PKG.begin_record
		(x_org_id		         => p_org_id,
		 x_Operation            => 'DELETE'
		 ,x_Rowid                 => G_ROWID
		 ,x_rt_quota_asgn_id      => l_rt_quota_asgn_id
		 ,x_calc_formula_id       => NULL
		 ,x_quota_id              => NULL
		 ,x_start_date            => NULL
		 ,x_end_date              => NULL
		 ,x_rate_schedule_id      => NULL
		 ,x_attribute_category    => NULL
		 ,x_attribute1            => NULL
		 ,x_attribute2            => NULL
		 ,x_attribute3            => NULL
		 ,x_attribute4            => NULL
		 ,x_attribute5            => NULL
		 ,x_attribute6            => NULL
		 ,x_attribute7            => NULL
		 ,x_attribute8            => NULL
		 ,x_attribute9            => NULL
		 ,x_attribute10           => NULL
		 ,x_attribute11           => NULL
		 ,x_attribute12           => NULL
		 ,x_attribute13           => NULL
		 ,x_attribute14           => NULL
		 ,x_attribute15           => NULL
		 ,x_last_update_date      => NULL
		 ,x_last_updated_by       => NULL
		 ,x_creation_date         => NULL
		 ,x_created_by            =>  NULL
		,x_last_update_login     =>  NULL
		,x_Program_type          =>  NULL,
		 x_object_version_number => l_object_version_number) ;
	    ELSE
	      RAISE FND_API.G_EXC_ERROR ;
	   END IF ;
	END LOOP;
   END IF;

   -- End of Delete API body.
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
      ROLLBACK TO delete_rt_quota_asgns;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_rt_quota_asgns;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO delete_rt_quota_asgns;
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
END Delete_rt_quota_Asgns;

END CN_RT_QUOTA_ASGNS_PVT ;

/
