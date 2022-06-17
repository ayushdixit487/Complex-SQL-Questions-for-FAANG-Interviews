/* write a query to find the winner in each group if two players scores are identical then consider the lowest player_id as winner.
*/

create table players
(player_id int,
group_id int)

insert into players values (15,1);
insert into players values (25,1);
insert into players values (30,1);
insert into players values (45,1);
insert into players values (10,2);
insert into players values (35,2);
insert into players values (50,2);
insert into players values (20,3);
insert into players values (40,3);

create table matches
(
match_id int,
first_player int,
second_player int,
first_score int,
second_score int)

insert into matches values (1,15,45,3,0);
insert into matches values (2,30,25,1,2);
insert into matches values (3,30,15,2,0);
insert into matches values (4,40,20,5,2);
insert into matches values (5,35,50,1,1);

select * from players
select * from matches

/* hints 
1. first take out the first_player and first_score from matches table and  then using union all combine it with second_players and second_score from matches table.
2. then take the sum of score by player as total_score and join the existing table with players table and then rank the score by descending order to get the winner player.
3. if there are identical rank in each group then consider the smallest player id as winner.
*/

/* Solution */

with t1 as
	(select first_player as player_id,first_score as score from matches
	union all
	select second_player as player_id,second_score as score from matches),
	player_match_score as
	(select player_id,sum(score) as total_score from t1 group by 1),
	t3 as
	(select p.group_id,pmc.player_id,pmc.total_score,
	 rank() over(partition by p.group_id order by pmc.total_score desc ) as rnk from players p
	join player_match_score pmc
	on p.player_id = pmc.player_id)
select group_id,min(player_id) as winner,total_score from t3 where rnk = 1
	group by 1,3
