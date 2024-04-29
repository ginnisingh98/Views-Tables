--------------------------------------------------------
--  DDL for Package Body IEM_AMV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_AMV_PVT" as
/* $Header: iemvamvb.pls 120.1 2005/06/10 12:34:50 appldev  $*/
G_PKG_NAME		varchar2(100):='IEM_AMV_PVT';
G_cat_tbl		category_tbl;

PROCEDURE get_categories (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      x_category_tbl out nocopy category_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2) IS

	l_api_name        	VARCHAR2(255):='get_categories';
	l_api_version_number 	NUMBER:=1.0;

	l_index		number:=0;
	l_out_index	number;

	l_cat_ids_tbl		jtf_number_table:=jtf_number_table();
	l_cat_names_tbl		jtf_varchar2_Table_100:=jtf_varchar2_Table_100();


	l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    	l_msg_count             NUMBER := 0;
    	l_msg_data              VARCHAR2(2000);

	IEM_ERROR_GET_SUB_CATEGORIES	EXCEPTION;

BEGIN
	SAVEPOINT search_message_pvt;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
	THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
   	IF FND_API.to_Boolean( p_init_msg_list )
   	THEN
     		FND_MSG_PUB.initialize;
   	END IF;

	-- Initialize API return status to SUCCESS
   	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_cat_ids_tbl.extend;
	l_cat_names_tbl.extend;

	select channel_category_id, channel_category_name bulk collect into l_cat_ids_tbl, l_cat_names_tbl
	from	amv_c_categories_vl
	where channel_category_name like '%'
	and channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
	and	application_id = 520
	and	parent_channel_category_id is null
	order by channel_category_name;

	-- First Value is NONE
	G_cat_tbl(l_index).category_id := '-1';
	G_cat_tbl(l_index).category_name := 'None';

	l_index := l_index + 1;

	FOR i IN l_cat_ids_tbl.FIRST..l_cat_ids_tbl.LAST LOOP

	--	x_category_tbl(l_index).category_id := l_cat_ids_tbl(i);
	--	x_category_tbl(l_index).category_name := '--' || l_cat_names_tbl(i);


		G_cat_tbl(l_index).category_id := l_cat_ids_tbl(i);
		G_cat_tbl(l_index).category_name := '--' || l_cat_names_tbl(i);

		l_index := l_index + 1;

		iem_amv_pvt.get_sub_categories (p_api_version_number => p_api_version_number,
 		  	      p_init_msg_list  => p_init_msg_list,
		    	      p_commit	  => p_commit,
			      p_category_id => l_cat_ids_tbl(i),
			      p_index	=> l_index,
			      p_string	=> '--',
			      x_index	=> l_out_index,
			      x_return_status => l_return_status,
  		  	      x_msg_count => l_msg_count,
	  	  	      x_msg_data  => l_msg_data);

		if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
         		raise IEM_ERROR_GET_SUB_CATEGORIES;
   	  	end if;

		l_index := l_out_index;


	END LOOP;

	FOR j IN 0..l_index-1 LOOP

		x_category_tbl(j).category_id := G_cat_tbl(j).category_id;
		x_category_tbl(j).category_name := G_cat_tbl(j).category_name;


	END LOOP;

-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
  WHEN IEM_ERROR_GET_SUB_CATEGORIES THEN
      	   ROLLBACK TO create_item_wrap_pvt;
           FND_MESSAGE.SET_NAME('IEM','IEM_ERROR_GET_SUBCAT');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO search_message_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO search_message_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO search_message_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
	FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);

END get_categories;



PROCEDURE get_sub_categories (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_category_id	IN	NUMBER,
			      p_index		IN	NUMBER,
			      p_string		IN	VARCHAR2,
			      x_index		OUT	NOCOPY NUMBER,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2) IS

	l_api_name        	VARCHAR2(255):='get_sub_categories';
	l_api_version_number 	NUMBER:=1.0;

	l_index		number:=0;
	l_out_index	number:=0;
	l_cat_count	number:=0;
	l_string	VARCHAR2(500);

	l_cat_ids_tbl		jtf_number_table:=jtf_number_table();
	l_cat_names_tbl		jtf_varchar2_Table_100:=jtf_varchar2_Table_100();

	l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    	l_msg_count             NUMBER := 0;
    	l_msg_data              VARCHAR2(2000);


	IEM_ERROR_GET_SUB_CATEGORIES	EXCEPTION;
BEGIN
	SAVEPOINT search_message_pvt;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
	THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
   	IF FND_API.to_Boolean( p_init_msg_list )
   	THEN
     		FND_MSG_PUB.initialize;
   	END IF;

	-- Initialize API return status to SUCCESS
   	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_cat_ids_tbl.extend;
	l_cat_names_tbl.extend;

	select count(*) into l_cat_count
	from	amv_c_categories_vl
	where channel_category_name like '%'
	and	 channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
	and	application_id = 520
	and	parent_channel_category_id = p_category_id
	order by channel_category_name;


	if (l_cat_count > 0) then
		select channel_category_id, channel_category_name bulk collect into l_cat_ids_tbl, l_cat_names_tbl
		from	amv_c_categories_vl
		where channel_category_name like '%'
		and	 channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
		and	application_id = 520
		and	parent_channel_category_id = p_category_id
		order by channel_category_name;

		x_index := p_index;

		FOR i IN l_cat_ids_tbl.FIRST..l_cat_ids_tbl.LAST LOOP

			l_string := '--' || p_string;

			G_cat_tbl(x_index).category_id := l_cat_ids_tbl(i);
			G_cat_tbl(x_index).category_name := l_string || l_cat_names_tbl(i);

			x_index := x_index + 1;

			iem_amv_pvt.get_sub_categories (p_api_version_number => p_api_version_number,
 		  	      p_init_msg_list  => p_init_msg_list,
		    	      p_commit	  => p_commit,
			      p_category_id => l_cat_ids_tbl(i),
			      p_index	=> x_index,
			      p_string	=> l_string,
			      x_index	=> l_out_index,
			      x_return_status => l_return_status,
  		  	      x_msg_count => l_msg_count,
	  	  	      x_msg_data  => l_msg_data);

			if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
				raise IEM_ERROR_GET_SUB_CATEGORIES;
   	  		end if;

		x_index := l_out_index;

		END LOOP;
	else
		x_index := p_index;
	end if;


-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION

   WHEN IEM_ERROR_GET_SUB_CATEGORIES THEN
      	   ROLLBACK TO create_item_wrap_pvt;
           FND_MESSAGE.SET_NAME('IEM','IEM_ERROR_GET_SUBCAT');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO search_message_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO search_message_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO search_message_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
	FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);

END get_sub_categories;

end IEM_AMV_PVT ;

/
