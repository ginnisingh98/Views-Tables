--------------------------------------------------------
--  DDL for Package Body IGW_STUDY_TITLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_STUDY_TITLES_PVT" AS
--$Header: igwvsttb.pls 115.8 2002/11/18 19:20:11 ashkumar ship $


PROCEDURE CREATE_STUDY_TITLE
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , x_study_title_id               OUT NOCOPY NUMBER
 , p_study_title                  IN VARCHAR2
 , p_enrollment_status		  IN VARCHAR2
 , p_protocol_number	          IN VARCHAR2
 , x_rowid                        OUT NOCOPY ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2)  IS


  l_study_title_id           NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_proposal_id              NUMBER;

  BEGIN
   if p_commit = fnd_api.g_true then
      savepoint create_study_title;
   end if;

    if fnd_api.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

  l_proposal_id := p_proposal_id;

/* No need to validate proposal number */
/*
  --PROPOSAL NUMBER
    --IF (p_proposal_id  is  null   OR p_proposal_id   = FND_API.G_MISS_NUM  ) THEN
      IGW_UTILS.GET_PROPOSAL_ID(
         p_context_field     => 'PROPOSAL_ID'
         ,p_proposal_number  => p_proposal_number
         ,x_proposal_id      => l_proposal_id
         ,x_return_status    => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
        x_return_status := 'E';
      END IF;
    END IF;
*/

    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;


     begin
       select IGW_STUDY_TITLES_S.NEXTVAL
       into   l_study_title_id
       from   dual;
     exception
      when others then
       x_return_status:= fnd_api.g_ret_sts_unexp_error;
       raise;
     end;

      IGW_STUDY_TITLES_TBH.INSERT_ROW (
       X_ROWID => x_rowid,
       X_STUDY_TITLE_ID => l_study_title_id,
       X_STUDY_TITLE => p_study_title,
       X_ENROLLMENT_STATUS  =>  p_enrollment_status,
       X_PROTOCOL_NUMBER => p_protocol_number,
       X_PROPOSAL_ID => p_proposal_id,
       X_RETURN_STATUS => l_return_status);

      x_return_status := l_return_status;

    l_msg_count := FND_MSG_PUB.count_msg;

    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
      IF p_commit = FND_API.G_TRUE THEN
         ROLLBACK TO create_study_title;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_study_title;
    END IF;
    x_return_status := 'E';
      Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);
  WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_STUDY_TITLES_PVT',
                            p_procedure_name => 'CREATE_STUDY_TITLE');
      Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);
  END CREATE_STUDY_TITLE;

------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_STUDY_TITLE
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_study_title_id               IN NUMBER
 , p_study_title                  IN VARCHAR2
 , p_enrollment_status		  IN VARCHAR2
 , p_protocol_number              IN VARCHAR2
 , p_rowid                        IN ROWID
 , p_record_version_number        IN NUMBER
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) IS

    l_msg_data                 VARCHAR2(250);
    l_msg_count                NUMBER;
    l_data                     VARCHAR2(250);
    l_msg_index_out            NUMBER;
    l_return_status            VARCHAR2(1);
    l_proposal_id              NUMBER;


BEGIN

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_study_title;
   END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

   l_proposal_id := p_proposal_id;

/* No need to validate proposal number */
/*
    --PROPOSAL NUMBER
    --IF (p_proposal_id  is  null   OR p_proposal_id   = FND_API.G_MISS_NUM  ) THEN
      IGW_UTILS.GET_PROPOSAL_ID(
         p_context_field     => 'PROPOSAL_ID'
         ,p_proposal_number  => p_proposal_number
         ,x_proposal_id      => l_proposal_id
         ,x_return_status    => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
        x_return_status := 'E';
      END IF;
    END IF;
*/

    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

      CHECK_LOCK(p_rowid
                ,p_record_version_number
                ,x_return_status );

      l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;


      IGW_STUDY_TITLES_TBH.UPDATE_ROW (
       X_ROWID => p_rowid,
       X_STUDY_TITLE_ID => p_study_title_id,
       X_STUDY_TITLE   => p_study_title,
       X_ENROLLMENT_STATUS => p_enrollment_status,
       X_PROTOCOL_NUMBER => p_protocol_number,
       X_PROPOSAL_ID => l_proposal_id,
       X_RECORD_VERSION_NUMBER => p_record_version_number,
       X_RETURN_STATUS => l_return_status);

       x_return_status := l_return_status;

    end if;


    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

 -- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := 'E';
      Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);

  WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_STUDY_TITLES_PVT',
                            p_procedure_name => 'UPDATE_STUDY_TITLE');
      Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);

  END UPDATE_STUDY_TITLE;
-------------------------------------------------------------------------------------------
PROCEDURE DELETE_STUDY_TITLE (
  p_init_msg_list                IN             VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN             VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN             VARCHAR2   := FND_API.G_FALSE
 ,p_study_title_id               IN             NUMBER
 ,p_record_version_number        IN             NUMBER
 ,x_rowid                        IN             VARCHAR2
 ,x_return_status                OUT NOCOPY            VARCHAR2
 ,x_msg_count                    OUT NOCOPY            NUMBER
 ,x_msg_data                     OUT NOCOPY            VARCHAR2)  is

l_msg_count NUMBER;
l_msg_data VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;


BEGIN
-- create savepoint
   IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT delete_study_title;
   END IF;

-- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

 CHECK_LOCK (x_rowid  => x_rowid
            ,p_record_version_number => p_record_version_number
            ,x_return_status => x_return_status) ;

 l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

 if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

     IGW_STUDY_TITLES_TBH.DELETE_ROW(
             x_rowid                    =>      x_rowid,
             x_study_title_id           =>      p_study_title_id,
             x_record_version_number    =>      p_record_version_number,
             x_return_status            =>      x_return_status);

  end if;

  l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;


  -- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := 'E';
      Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);

  WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_study_title;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_STUDY_TITLES_PVT',
                            p_procedure_name => 'DELETE_STUDY_TITLE');
    Fnd_Msg_Pub.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data);
END;


-------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
                (x_rowid                        IN      VARCHAR2
                ,p_record_version_number        IN      NUMBER
                ,x_return_status                OUT NOCOPY     VARCHAR2) is
 l_dummy integer;
 BEGIN
   select 1
   into l_dummy
   from igw_study_titles
   where rowid = x_rowid
   and record_version_number = p_record_version_number;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
          FND_MSG_PUB.Add;
          raise fnd_api.g_exc_error;

    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_STUDY_TITLES_PVT',
                                  p_procedure_name => 'CHECK_LOCK');
          raise fnd_api.g_exc_unexpected_error;


END CHECK_LOCK;

END IGW_STUDY_TITLES_PVT;

/
