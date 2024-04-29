--------------------------------------------------------
--  DDL for Package Body CUG_INCIDNT_ATTR_VALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_INCIDNT_ATTR_VALS_PVT" as
/* $Header: CUGRINTB.pls 115.10 2004/01/27 00:27:17 aneemuch ship $ */

       G_PKG_NAME  CONSTANT     VARCHAR2(100) := 'CUG_INCIDNT_ATTR_VALS_PVT';


procedure CREATE_RUNTIME_DATA  (
		p_api_version    IN   NUMBER,
		p_init_msg_list  IN   VARCHAR2  := FND_API.G_FALSE,
		p_commit	 IN 	VARCHAR   := FND_API.G_FALSE,
		p_sr_tbl  	IN 	OUT NOCOPY sr_tbl,
		x_msg_count		OUT  NOCOPY NUMBER,
		x_msg_data		OUT  NOCOPY VARCHAR2,
		x_return_status	OUT  NOCOPY VARCHAR2 )
		is
		l_api_name     CONSTANT       VARCHAR2(30)   := 'CUG_INCIDNT_ATTR_VALS_PVT';
		l_api_version  CONSTANT       NUMBER         := 1.0;
		l_sr_id                 NUMBER         :=FND_API.G_MISS_NUM;
		l_current_date                DATE           :=sysdate;
		l_created_by                  NUMBER         := fnd_global.user_id;
		l_login                       NUMBER        :=fnd_global.login_id;
		l_rowid                       VARCHAR2(100);
		l_date_format			VARCHAR2(100);
		l_num_rec number ;
		l_incident_id  number;
		l_sr_attr_code varchar2(30);
		l_sr_attr_value varchar2(1997);
       	l_sr_tbl  CUG_INCIDNT_ATTR_VALS_PVT.sr_tbl;

--Begin -  To fix bug # 2440305
    l_incident_type_id NUMBER;
    CURSOR l_CheckIfSRHdrInfoPresent_csr IS
       select INCIDENT_TYPE_ID, SR_ATTRIBUTE_CODE from CUG_SR_TYPE_ATTR_MAPS_B
        WHERE INCIDENT_TYPE_ID = l_incident_type_id;
    l_CheckIfSRHdrInfoPresent_rec l_CheckIfSRHdrInfoPresent_csr%ROWTYPE;
--End -  To fix bug # 2440305

begin
--Begin -  To fix bug # 2440305

    -- Fix for bug 2505327. Changed table index from 0 to 1. rmanabat 08/13/02.
    l_incident_id := p_sr_tbl(1).incident_id;

    SELECT incident_type_id into l_incident_type_id from cs_incidents_all_b where incident_id = l_incident_id;
    OPEN l_CheckIfSRHdrInfoPresent_csr;
    FETCH l_CheckIfSRHdrInfoPresent_csr into l_CheckIfSRHdrInfoPresent_rec;
    IF(l_CheckIfSRHdrInfoPresent_csr%NOTFOUND) THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
--End -  To fix bug # 2440305
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	 -- Initialize message list if p_init_msg_list is set to TRUE.

 l_num_rec :=    p_sr_tbl.count;
   IF l_num_rec > 0
   THEN
      FOR i IN 1..l_num_rec
      LOOP
		p_sr_tbl(i).override_addr_valid_flag := 'N';
		p_sr_tbl(i).OBJECT_VERSION_NUMBER := null;
		p_sr_tbl(i).ATTRIBUTE1 := null;
		p_sr_tbl(i).ATTRIBUTE2 := null;
		p_sr_tbl(i).ATTRIBUTE3 := null;
		p_sr_tbl(i).ATTRIBUTE4 := null;
		p_sr_tbl(i).ATTRIBUTE5 := null;
		p_sr_tbl(i).ATTRIBUTE6 := null;
		p_sr_tbl(i).ATTRIBUTE7 := null;
		p_sr_tbl(i).ATTRIBUTE8 := null;
		p_sr_tbl(i).ATTRIBUTE9 := null;
		p_sr_tbl(i).ATTRIBUTE10 := null;
		p_sr_tbl(i).ATTRIBUTE11 := null;
		p_sr_tbl(i).ATTRIBUTE12 := null;
		p_sr_tbl(i).ATTRIBUTE13 := null;
		p_sr_tbl(i).ATTRIBUTE14 := null;
		p_sr_tbl(i).ATTRIBUTE15 := null;
		p_sr_tbl(i).ATTRIBUTE_CATEGORY := null;


		BEGIN
			SELECT lookup_code
			INTO	l_sr_attr_code
			FROM   FND_LOOKUPS
			WHERE  lookup_type = 'CUG_SR_TYPE_ATTRIBUTES'
			and   description  = p_sr_tbl(i).sr_question  ;

		EXCEPTION
			When NO_DATA_FOUND then
			     FND_MESSAGE.SET_NAME('CUG','CUG_INVALID_SR_TYPE_QUESTION');
				FND_MSG_PUB.ADD;
	 			l_sr_attr_code 	:= null;
			When OTHERS then
			     FND_MESSAGE.SET_NAME('CUG','CUG_INVALID_SR_TYPE_QUESTION');
				FND_MSG_PUB.ADD;
	 			l_sr_attr_code 	:= null;
		END;


		select CUG_INCIDNT_ATTR_VALS_B_S.NEXTVAL
		into p_sr_tbl(i).incidnt_attr_val_id
		from dual;


      CUG_INCIDNT_ATTR_VALS_PKG.INSERT_ROW (
          X_ROWID => l_rowid,
	  X_INCIDNT_ATTR_VAL_ID => p_sr_tbl(i).incidnt_attr_val_id ,
  	  X_OBJECT_VERSION_NUMBER  => p_sr_tbl(i).OBJECT_VERSION_NUMBER,
	  X_INCIDENT_ID  => p_sr_tbl(i).incident_id ,
	  X_SR_ATTRIBUTE_CODE  =>l_sr_attr_code,
  	  X_OVERRIDE_ADDR_VALID_FLAG  => p_sr_tbl(i).override_addr_valid_flag,
	  X_ATTRIBUTE1 =>p_sr_tbl(i).ATTRIBUTE1,
	  X_ATTRIBUTE2 => p_sr_tbl(i).ATTRIBUTE2,
	  X_ATTRIBUTE3=> p_sr_tbl(i).ATTRIBUTE3,
	  X_ATTRIBUTE4 => p_sr_tbl(i).ATTRIBUTE4,
	  X_ATTRIBUTE5 => p_sr_tbl(i).ATTRIBUTE5,
	  X_ATTRIBUTE6 =>p_sr_tbl(i).ATTRIBUTE6,
	  X_ATTRIBUTE7 => p_sr_tbl(i).ATTRIBUTE7,
	  X_ATTRIBUTE8 => p_sr_tbl(i).ATTRIBUTE8,
	  X_ATTRIBUTE9 => p_sr_tbl(i).ATTRIBUTE9,
	  X_ATTRIBUTE10 => p_sr_tbl(i).ATTRIBUTE10,
	  X_ATTRIBUTE11 => p_sr_tbl(i).ATTRIBUTE11,
	  X_ATTRIBUTE12 => p_sr_tbl(i).ATTRIBUTE12,
	  X_ATTRIBUTE13 => p_sr_tbl(i).ATTRIBUTE13,
	  X_ATTRIBUTE14 => p_sr_tbl(i).ATTRIBUTE14,
	  X_ATTRIBUTE15 => p_sr_tbl(i).ATTRIBUTE15,
	  X_ATTRIBUTE_CATEGORY=> p_sr_tbl(i).ATTRIBUTE_CATEGORY ,
          X_SR_ATTRIBUTE_VALUE =>  p_sr_tbl(i).sr_answer   ,
	  X_CREATION_DATE =>l_current_date,
	  X_CREATED_BY => l_created_by,
	  X_LAST_UPDATE_DATE => l_current_date,
	  X_LAST_UPDATED_BY =>l_created_by,
	  X_LAST_UPDATE_LOGIN => l_login
	  );
END LOOP;
end if;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;


--Begin -  To fix bug # 2440305
END IF;
CLOSE l_CheckIfSRHdrInfoPresent_csr;
--End -  To fix bug # 2440305

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded=> FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded=> FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded=> FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END CREATE_RUNTIME_DATA;

/* Changed for 9i compatibility bug 2543479 .. the parameters should
   match the declarations in the Spec
   p_init_msg_list      IN      VARCHAR2  DEFAULT NULL              	,
   p_commit             IN      VARCHAR2  DEFAULT NULL              	, */

PROCEDURE LAUNCH_WORKFLOW(
			p_api_version        IN      NUMBER                                     ,
			p_init_msg_list      IN      VARCHAR2    := FND_API.G_FALSE              ,
			p_commit             IN      VARCHAR2    := FND_API.G_FALSE              ,
			x_return_status      OUT     NOCOPY VARCHAR2                                   ,
			x_msg_count          OUT     NOCOPY NUMBER                                     ,
			x_msg_data           OUT     NOCOPY VARCHAR2                                   ,
			p_incident_id        IN      NUMBER                                     ,
			p_source             IN      VARCHAR2 DEFAULT NULL )
  IS

    l_api_name	     CONSTANT 	   VARCHAR2(30)  := 'launch_workflow' ;
    l_api_version   CONSTANT 	   NUMBER   	  := 1.0  		   ;

    l_itemkey VARCHAR2(240);
    l_wf_process_id NUMBER;
    l_initiator_role VARCHAR2(100);
    l_initiator_display_name VARCHAR2(240);

	CURSOR l_servereq_csr IS
	SELECT	CSI.incident_number,
		CSI.workflow_process_id,
		CSI.incident_type_id,
		CST.name,CST.workflow,
		CST.autolaunch_workflow_flag
	FROM	cs_incidents_all_b CSI, cs_incident_types_vl CST
	WHERE	CSI.incident_id = p_incident_id
	AND	CST.incident_type_id = CSI.incident_type_id
	FOR UPDATE OF workflow_process_id NOWAIT;

	l_servereq_csr_rec l_servereq_csr%ROWTYPE;

  BEGIN
    --Initialize message listif p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

      IF (p_incident_id IS NOT NULL ) THEN

        OPEN l_servereq_csr;
        FETCH l_servereq_csr INTO l_servereq_csr_rec;
--        EXIT WHEN l_servereq_csr%NOTFOUND;

        -- Construct the unique item key
        SELECT cs_wf_process_id_s.NEXTVAL INTO l_wf_process_id FROM DUAL;
        l_itemkey := l_servereq_csr_rec.incident_number || '-' || to_char(l_wf_process_id);

        -- Update the workflow process ID of the request
        IF TO_NUMBER(FND_PROFILE.VALUE('USER_ID')) IS NOT NULL THEN
          UPDATE	CS_INCIDENTS_ALL_B
          SET	workflow_process_id = l_wf_process_id,
		last_updated_by = TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
		last_update_date = sysdate
          WHERE CURRENT OF l_ServeReq_csr;
        ELSE
		UPDATE	CS_INCIDENTS_ALL_B
		SET	workflow_process_id = l_wf_process_id,
			last_update_date = sysdate
		WHERE CURRENT OF l_ServeReq_csr;
        END IF;


        IF l_servereq_csr_rec.workflow is not null  THEN

          wf_engine.CreateProcess (Itemtype => 'SERVEREQ',
                                   Itemkey  => l_itemkey,
                                   process  => l_servereq_csr_rec.workflow);

          wf_engine.startprocess (itemtype => 'SERVEREQ',
                                  itemkey  => l_itemkey);

	END IF;
-- Commented the following and added above if condition to take care of the
-- condition when no workflow is associated  06/14/2002

/*
        IF (p_source = 'FORM') THEN

          wf_engine.CreateProcess (Itemtype => 'SERVEREQ',
                                   Itemkey  => l_itemkey,
                                   process  => l_servereq_csr_rec.workflow);

          wf_engine.startprocess (itemtype => 'SERVEREQ',
                                  itemkey  => l_itemkey);

        ELSE

          wf_engine.CreateProcess (Itemtype => 'SERVEREQ',
                                   Itemkey  => l_itemkey,
                                   process  => 'CUG_GENERIC_WORKFLOW');

          wf_engine.startprocess (itemtype => 'SERVEREQ',
                                  itemkey  => l_itemkey);

        END IF;
*/

      END IF;

	-- Endof API body.

    -- Standard check for p_commit.
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;


    -- Standard call to get messgage count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_get (
                              p_count   => x_msg_count,
                              p_data    => x_msg_data
                              );


    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        IF (l_servereq_csr%ISOPEN) THEN
          CLOSE l_servereq_csr;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
                                (
                                p_count     => x_msg_count,
                                p_data      => x_msg_data
                                );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_servereq_csr%ISOPEN) THEN
          CLOSE l_servereq_csr;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
                                (
                                p_count     => x_msg_count,
                                p_data      => x_msg_data
                                );

      WHEN OTHERS THEN
        IF (l_servereq_csr%ISOPEN) THEN
          CLOSE l_servereq_csr;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level
          ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
                                (
                                G_PKG_NAME,
                                l_api_name
                                );
        END IF;
        FND_MSG_PUB.Count_And_Get
                                (
                                p_count => x_msg_count,
                                p_data => x_msg_data
                                );

  END launch_workflow;


 PROCEDURE Create_Address_Note (
		p_api_version    IN   NUMBER,
		p_init_msg_list  IN   VARCHAR2  := FND_API.G_FALSE,
		p_commit	 IN 	VARCHAR   := FND_API.G_FALSE,
		p_incident_id IN Number,
		x_msg_count		OUT  NOCOPY NUMBER,
		x_msg_data		OUT  NOCOPY VARCHAR2,
		x_return_status	OUT  NOCOPY VARCHAR2 ,
		x_note_id OUT NOCOPY NUMBER )
 is
	l_return_status VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS ;
	l_msg_data VARCHAR2(240) := null;
	l_commit   VARCHAR2(1) := FND_API.G_FALSE;
	l_addr_notes	VARCHAR2(2000) := null;
	l_msg_count	NUMBER;
	l_login_id	NUMBER := 0 ;
	l_created_by_user_id 	NUMBER := 0;
	l_incident_id	NUMBER := p_incident_id ;
	l_note_context_tab_dflt JTF_NOTES_PUB.jtf_note_contexts_tbl_type;


Begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--dbms_output.put_line( ' Came Here 10'  || x_return_status );
 	-- Changed from CHR(10) to '' to Comply with GSCC Error for New Line File.SQL.10
	-- P.S DO NOT TRY TO INDENT THIS CODE SINCE IT WILL EFFECT THE NEW LINE CHAR
Begin

	Select 'Incident Address ' ||'
' || 'Address : ' || nvl(incident_address, '    ') || '
' || 'City : ' || nvl(incident_city, ' ') || '
' || 'State : ' || nvl(incident_state, ' ') ||  '
' || 'Postal Code : ' || nvl(incident_postal_code, ' ') ||  '
' || 'Country : ' || nvl(incident_country, ' ')
	into	 l_addr_notes
	From 	cs_incidents_all_b
	Where 	incident_id = l_incident_id;
EXCEPTION
        When NO_DATA_FOUND then
		null;
	--			dbms_output.put_line( ' Came Here 20 No Data Found'  || x_return_status );
END;



	/* May be add these also
		 incident_province
		 incident_county
	*/
--	dbms_output.put_line( ' Came Here 30'  || x_return_status );
--	dbms_output.put_line( ' Came Here 40'  || l_addr_notes );
	JTF_NOTES_PUB.Create_note (
                p_api_version   => 1.0 ,
		p_init_msg_list => 'T',
                p_commit => l_commit,
		p_validation_level => csc_core_utils_pvt.g_valid_level_none,
                x_return_status => l_return_status ,
                x_msg_count  => l_msg_count,
                x_msg_data  => l_msg_data ,
                p_source_object_id => l_incident_id,
                p_source_object_code => 'SR',
                p_notes => l_addr_notes ,
                p_entered_by => l_created_by_user_id,
                p_entered_date => sysdate,
	        x_jtf_note_id  => x_note_id ,
	        p_last_update_date => sysdate,
   	        p_last_updated_by => l_created_by_user_id,
     	      	p_creation_date  => sysdate,
     	      	p_created_by => l_created_by_user_id,
     	      	p_last_update_login => l_login_id,
	        p_note_type => 'CUG_SR_ATTR_DETAILS',
		p_jtf_note_contexts_tab => l_note_context_tab_dflt
      );
/*
	dbms_output.put_line( ' Came Here 50'  || x_return_status );
dbms_output.put_line( 'x_note_id is ' || x_note_id );
dbms_output.put_line( 'l_return_status is ' || l_return_status );
dbms_output.put_line( 'l_msg_data is ' || l_msg_data );

*/
   -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded=> FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded=> FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded=> FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);


END Create_Address_Note;

end  CUG_INCIDNT_ATTR_VALS_PVT ;

/
