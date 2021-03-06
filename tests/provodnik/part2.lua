include 'titles'

game.pic = false
dlg {
	nam = 'main';
	title = '???';
	enter = function()
		p [[Боль и темнота. Боль и темнота, а еще паника. Паника заполняла меня целиком,
волнами. По мере того как я приходил в себя, я все больше и больше желал снова впасть в забытье.
Но я приходил в себя... Нехотя я открыл глаза.]];
		game.pic = 'gfx/eye.png'
		snd.music 'mus/provodnik1.ogg'
	end;
dsc = [[Передо мной сидела та тварь, и что-то говорила. Хрипловатым, угрюмым голосом.
Я попытался вникнуть в то, что она или оно говорит...]];
	phr = { only = true;
		'-- Вадим Владимирович, вы слышите меня?',
		{ 'Да', '-- Очень хорошо, тогда слушайте внимательно.', next = '#да',
		  { '#да', '-- Проводник неверно оценил вашу стоимость. Поэтому у меня есть для вас предложение',
		    onempty = function(s)
			    push '#desc'
		    end;
		    { 'Стоимость?', '-- Да, вашу оценочную стоимость следует поднять раз в 15. Конечно, проводнику будет сделан выговор... Хотя вы -- ценное приобретение.'},
		    { 'Проводник?', '-- Да, тот проводник, благодаря которому мы вас получили. Я не знаю точно, кто это был. Вероятно тот, кого вы встретили первым, когда началась череда передач от одних проводников к другим...'},
		    { 'Предложение?', '-- Да, это предложение очень важно для вас. Сделайте верный выбор...' },
		    { 'Где я?', '-- Вы на моем корабле. Это транспорт, мы только что вышли из туннеля, и скоро прибудем на рынок.',
		      {'Рынок?', '-- Да, рынок. Нелегальный рынок работорговцев.',
		       {'Рабы?', '-- Ха-ха-ха -- вы так ничего не поняли? Да -- вы все -- мои рабы. Вселенная огромна, а рабов всегда не хватает. Особенно сейчас, когда нас захлестнула новая волна колонизаций. Нам нужны рабы, и хотя власти делают вид, что борятся с работорговлей, это только видимость.'},
		      },
		      {'Корабль?', '-- Вам будет понятней, если я назову его зведолетом? Извольте, вы -- на моем звездолете.'},
		    }
		  }
		},
		{ 'Нет', '-- Вы шутите... Это хорошо.', next = '#да' },
		{ only = true, false, '#desc',
		  [[-- Ладно, я вижу у вас слишком много вопросов. Тогда послушайте меня.
Факты просты. Вы -- раб. Лучшее, что вас ждет -- работы на рудниках Ноутса-17. Но для меня вы представляете
некую ценность.. Вы сами -- можете стать проводником...^
Это не даст вам свободу, но спасет от мучительной жизни и, вероятно, скорой кончины.]],
		  {'Никогда', '-- Я бы на вашем месте не принимал бы таких важных решений так поспешно.', next = '#details' },
		  {'Нужны подробности.', '-- Мне это нравится! Слушайте!', next = '#details',
		   { '#details', onempty = function()
			     push '#desc2'
		   end,
		     [[Итак, проводники -- это бывшие особи вашей планеты...]],
		     {'Бывшие?', '-- Да. Прежде, чем стать проводником, вы подвергнетесь гм... процедуре.',
		      {'Процедуре?',
		       [[-- Процедура, которая проводится специальным образом, изменит ваше подсознание, или душу -- если угодно, таким образом, что вы потеряете некие особенности, присущие вашему роду...]],
		       {'Какие особенности?', [[-- Сущий пустяк, у вас не будет колебаний. В каком то смысле,
вы станете сильней. То, что ваш вид называет: совестью, долгом, любовью -- это умрет. Вообще, это давно уже атавизм,
только на недоразви... гм.. планетах, типа вашей Земли -- остались эти нелепости... У вас не будет колебаний... Вы сможете служить нам по совести... Вернее, гм, без колебаний. Не предадите нас. Но при этом, ваша жизнь будет комфортна! Ни это ли вы любите больше всего?]]
		       },
		       {'Зачем вы меня предупреждаете?', [[-- Я бы не предупредил, если бы процедура не требовала от вас
искреннего желания измениться, в противном случае -- вы потеряете рассудок, и мы потеряем деньги, простите за прямоту. Хотя мы, конечно, стараемся использовать и таких... особей... Но их применимость сильно ограничена.]]
		       }
		      },
		     },
		   },
		  },
		  {'Да, легко!', '-- Ваше рвение мне нравится, но есть нюансы...', next = '#details'}
		},
		{
			false, '#desc2',
			onempty = function()
				instead.nosave = true
				instead.noautosave = true
				instead.autosave()
				push '#choice'
			end;
			[[С этими словами он внимательно посмотрел на меня своими маленькими глазками... Было что-то гипнотическое
в его словах. Они были такими... простыми... Никаких угрызений совести, никаких бытовых проблем... Но в этот момент я почему-то
вспомнил угрюмый взгляд сумасшедшего проводника, который провожал наш поезд... Потом я вспомнил жену, ссору и ту боль,
которую -- я знал! -- я причинил ей. Она думает, что я бросил ее, наверное... Я ушел из дому, сколько меня не было? День или два?]],
			{'Но тогда у меня не будет свободы воли?',
			 [[-- Если вы считаете эту шизофрению -- свободой воли, то ее у вас не будет.]]},
			{'И я не буду чувствовать угрызений совести?', [[-- Никаких!]]},
			{'Я буду счастлив?', [[-- Я не смогу ответить вам на этот вопрос. Это зависит от вас.]]},
			{'Сколько я буду жить?', [[-- Около 200 лет, так как вы сможете воспользоваться нашей омолаживающей медициной.]]},
			{'А если я откажусь?', [[-- Мне будет жаль, так как вы принесли бы гораздо больше прибыли.
Но тогда вас ждет настоящее рабство.]],
				 {'То-есть, я в любом случае, не увижу свою жену снова?',
				  [[-- Никогда, совершенно точно и абсолютно. Если вас это беспокоит, я бы рекомендовал вам избавиться от угрызений совести тем способом, о котором мы говорим.]]
				 }
			}
		},
		{
			false, '#choice',
			[[-- Итак, теперь вы можете сделать выбор, Вадим Владимирович... Я жду вашего решения.]],
			{'А мне можно еще подумать?', [[-- Увы, вам придется дать ответ сейчас. Мы скоро прибываем.
Рейсы сюда, все-таки, связаны с определенной долей риска. Вы понимаете, я не могу вернуться сюда, если вы передумаете...
Так что я потеряю вашу стоимость, которая на данный момент явно выше 230 кредитов.]]},
			{'А кто вы такой?', [[-- Я? Для вас я капитан и ваш хозяин.]] },
			{'Хорошо, я готов сделать выбор.', '-- Ваша стоимость растет ежеминутно! Итак, ваш выбор?',
			 { cond = function() return prefs.choice == 1 or not prefs.choice end,
			   'Иди к черту, грязный ублюдок!', function() prefs.choice = 1; prefs:store(); walk 'choice1' end },
			 { cond = function() return prefs.choice == 2 or not prefs.choice end,
			   'Я готов стать проводником.', function() prefs.choice = 2; prefs:store(); walk 'choice2' end },
			 { cond = function() return prefs.choice end, 'Почему я не могу изменить выбор?',
			    [[Я же сказал, что это очень ВАЖНЫЙ ВЫБОР!!! Ха-ха-ха-ха... Ты думал, что можно попробовать выбрать по-разному?]],
			    {only = true, onempty = function() prefs.choice = false; pop(); end,
			     'Ну я очень хочу изменить свой выбор!', '-- Нет, ну ты правда думал, что это игра?',
			     { 'Да, это игра.', '-- Иногда я и сам так думаю. Ну хорошо, можешь попробовать...' },
			     { 'Это не игра, просто дай мне сменить выбор.', '-- Мне кажется, что я переоценил твои способности. Ладно, давай...'},
			    }
			 },
			},
		}
	}
}
room {
	nam = 'choice1';
	title = '...';
	onenter = function()
		instead.nosave = false
		instead.noautosave = false
		snd.music 'mus/bensound-pianomoment.ogg'
	end;
	decor = function()
		p(fmt.c((fmt.y('50%','middle')..'{@ walk "В кафе"|Прошло 5 лет...}')))
	end;
};

room {
	nam = 'choice2';
	title = 'Конец?';
	onenter = function()
		instead.nosave = false
		instead.noautosave = false
		snd.music 'mus/bensound-sadday.ogg'
	end;
	decor = function()
		p(fmt.c((fmt.y('50%','middle')..'{@ walk "На улице"|Прошло 5 лет...}')))
	end;
};

wife = obj {
	dsc = function(s)
		if s.run then
			p [[Я вижу как {женщина} спешит к углу здания.]];
			return
		end
		p [[Под аркой стоит {женщина}.]];
	end;
	step = 0;
	run = false;
	pos = 1;
	life = function(s)
		s.step = s.step + 1
		if s.step > 2 then
			place(s)
			lifeoff(s)
			return [[В арку вбежала женщина. Заметив меня она сначала замешкалась, но затем
подбежала ко мне и быстро спросила:^-- Где здесь аптека? Там человеку плохо...]], true
		end
	end;
	{
		text = {
			[[Во мне что-то шевельнулось. Какое-то забытое воспоминание. Да -- это она. Я знал это и раньше.]],
			[[Но мне было все-равно. Так что же изменилось?]],
			[[Я не понимал. Но вот, снова... Что-то жгло меня изнутри.]],
			[[Это кольцо. Прошло пять лет, но она носит его.]],
			[[Кольцо, которое я надел ей в день нашей свадьбы...]],
			[[Я чувствую, как что то жгучее взрывается в моей груди, в моем сердце...]],
			[[Заливает мои глаза, лицо... Я вытираю слезы, я иду за ней...]],
			[[Я кричу ей, кричу, чтобы она остановилась.]],
			[[Я бегу за ней. Рыдая и спотыкаясь...]],
			[[Я знаю, что у меня нет шансов, но я также знаю, что у меня нет выбора.]],
			[[Я знаю, что я мертв. Но она, она жива, я должен спасти ее...]],
		}
	};
	act = function(s)
		if s.run then
			p (s.text[s.pos])
			s.pos = s.pos + 1
			if s.pos > #s.text then
				walk 'end2'
			end
		else
			p [[-- Да, конечно, вот сейчас повернете налево и будет подвальчик, спуститесь туда и будет
вам аптека. -- Сказал я заученную фразу.^]]
			p [[-- Спасибо! -- она взглянула на меня, в свете света окон я увидел как блеснуло ее обручальное кольцо. Но вот, она уже спешит за угол здания. Спешит туда, откуда никогда не вернется...]]
			s.run = true
		end
	end;
}

room {
	nam = 'На улице';
	enter = function()
		p [[Все было уже подготовлено. Монета лежала там, где ее нельзя было не заметить.
Я ждал когда особь, направляемая предыдущим проводником, окажется в моей области влияния...^
На этот раз это была женщина.]];
		game.pic = 'gfx/street2.png'
	end;
	decor = function()
		p [[Поздний вечер, я стою под аркой темного {#переулок|переулка} и жду.]]
	end;
}: with
{
	obj {
		nam = '#переулок';
		act = function(s)
			if seen(wife) then
				p [[В переулке только я и она. Больше никого.]]
				return
			else
				p [[Я слышу стук женских каблуков... Уже скоро...]]
				lifeon(wife)
			end
		end
	}
}

room {
	nam = 'В кафе';
	title = 'В пивной';
	enter = function()
		p [[-- Ну и что, что было дальше? -- Владимир не скрывает своего интереса, хотя
в уголках его глаз я вижу скрытое лукавство.]];
		game.pic = 'gfx/beer.png'
	end;
	decor = [[Мы сидим за столом. Поздний вечер. Я вижу перед собой кружку с {#пиво|пивом}. Напротив меня за столом сидит
{#Владимир|Владимир}. Он с интересом наблюдает за мной. Слева и справа от меня находятся {#Сергей|Сергей} и {#Илья|Илья}.]];
	obj = {
		obj {
			nam = '#пиво';
			act = [[Я отхлебнул немного пива.]];
		};
		obj {
			nam = '#Владимир',
			pos = 1;
			{
				text = {
					[[-- Ну, потом я пять лет работал на рудниках Нотуса-17.]],
					[[-- Должен заметить, это был не худший вариант.]],
					[[-- Хотя с нашего привоза выжило процентов 30% рабов.]],
					[[-- И каждый день кто-нибудь умирал.]],
					[[-- Но ты выбрался? -- Владимир уже не скрывал своего скепсиса.]],
					[[-- Да, каждый год транспорт привозил новых рабов.]],
					[[-- Вместе с остальными нам удалось захватить транспорт...]],
					[[-- Мы добрались на нем до ближайших ворот.]],
					[[-- Ну а дальше, я пробрался на корабль работорговца, который и вернул меня сюда...]],
					[[-- Вот значит как? -- смеется Владимир. Но я не замечаю его смеха.]],
					[[-- Да, так все и было...]],
					[[-- А мы все думали, куда ты пропал? -- говорит Владимир -- Так все-таки, где ты был, приятель?]];
					[[-- Черт возьми, я же сказал! -- в сердцах я ударил кулаком по столу, немного расплескав пиво. -- Впрочем, я не виню вас.]];
					[[-- Она тоже не поверила. Хотя только благодаря ей я и прошел через это все...]],
					[[-- Я просто не мог умереть. Не мог сидеть сложа руки. Каждый день, каждый вечер, каждый час, каждую минуту я думал о той боли, что она испытывает. Она ведь думала, что я бросил ее! Ушел -- и не вернулся...]],
					[[-- Угрызения совести и желание исправить все двигало мной, я разработал план и он сработал! Но не моя заслуга в этом... Нет... Простите, ребята, я не могу говорить...]],
					[[-- Значит, она не поверила? -- спрашивает Владимир.]],
					[[-- Нет, не поверила. Я не знаю, мне пришлось соврать, что я просто уехал, сбежал. Но знаете...]],
					[[-- Хоть она и не поверила мне...]],
					[[-- Она меня простила. И это все, что мне нужно.]],
					[[-- Ну теперь-то все хорошо? -- спрашивает Владимир.]],
					[[-- Да, теперь я счастлив. Снова счастлив, как когда-то...]],
					[[-- Но есть что-то, что мешает моему счастью...]],
					[[-- Нечто, что я знаю теперь, существует. Проводники. Они вокруг нас.]],
					[[-- Ждут своего часа, следят за нами. И многие становятся их жертвами.]],
					[[-- Стать рабом, это плохо. Но еще хуже -- стать одним из них...]],
					[[-- Капитан обманул меня, проводник не может быть счастливым...]],
					[[-- Проводник -- это мертвец. И я не знаю, можно ли его вернуть к жизни.]],
					[[-- Иногда мне становится страшно даже от мысли, от самой возможности, что я мог бы стать проводником сам...]];
					[[-- Так что, ребята, если случится с вами подобное, никогда не верьте капитану!]],
				}
			};
			act = function(s)
				p(s.text[s.pos])
				s.pos = s.pos + 1
				if s.pos > #s.text then
					walk 'end1'
				end
			end;
		};
		obj {
			nam = '#Сергей',
			act = [[Сергей хитро улыбается, глядя на мои пьяные глаза.]];
		};
		obj {
			nam = '#Илья',
			act = [[Илья сдержанно грызет сухарик.]];
		};
	}
}
local titles = function(s)
	pn(fmt.y ('30%', 'bottom'))
	pn(fmt.c(fmt.b 'ПРОВОДНИК'))
	pn(fmt.c('Игра Петра Косых на движке STEAD3'))
	pn(fmt.c('Февраль 2017'))
	pn(fmt.c 'КОНЕЦ')
end
room {
	nam = 'end2';
	title = false;
	enter = function()
		game.pic = 'gfx/coin.png'
		timer:set(10000)
	end;
	timer = function()
		timer:stop()
		end_titles()
	end;
	decor = function(s)
		pn [[Я должен спасти ее!...]]
		titles()
	end
}

room {
	nam = 'end1';
	title = false;
	enter = function()
		game.pic = 'gfx/ring.png'
		timer:set(10000)
	end;
	timer = function()
		timer:stop()
		end_titles()
	end;
	decor = function(s)
		pn [[Ох, ребята, уже поздно, мне надо идти... Домой...]]
		titles()
	end;
}

function start()
	if ontitles then
		end_titles()
	end
end

function init()
end
