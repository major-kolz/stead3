require "fmt"
fmt.para = true
require "noinv"
require "nolife"
require "fmt"
dlg.noinv = true
dlg.nolife = true

function scene(v)
	v.noinv = true
	v.nolife = true
	v.num = 1
	if type(v.decor) == 'string' then
		v.__decor = { v.decor }
	else
		v.__decor = v.decor
	end
	v.decor = function(s)
		return s.__decor[v.num]
	end
	v.obj = {
		obj { dsc = '{Дальше}';
		      act = function(s)
			      instead.need_fading(true)
			      v.num = v.num + 1;
			      if v.num > #v.__decor then
				      walk(v.next)
			      end
		      end
		}
	};
	return room(v)
end

scene {
	nam = 'main';
	title = '';
	next = 'r2';
	decor = {
		[[С тех пор, как в НИИ появились военные, Петр не находил себе места.
Не смотря на то, что генерал вел себя подчеркнуто вежливо по отношению к работникам института
и того же требовал от своих солдат, Петр остро чувствовал что-то вроде нездоровой ревности.^^
Но если это чувство, которое теперь мешало ему работать, он еще мог в себе заглушить,
то обиду и гнев за ограничение свободы в исследованиях -- никогда!]];
		[[Последний раз, когда портал открылся снова и Валерка запустил в
него дрона, Петр намеревался сам пройти через загадочный переход и провести исследования.
Но его не пустили эти дуболомы генерала! Не пустили его -- Петра, в
собственной лаборатории!]],
		[[Письменное разрешение генерала, которое требовали солдафоны, удалось получить
только через несколько часов. Так как генерала срочно вызвали в Министерство обороны, и его не было
на месте. Но вскоре после этого, портал схлопнулся и Петр кусал от досады локти.]];
		[[Но такого больше не повторится! Петр взломал веб-камеру, установленную в лаборатории
и теперь круглосуточно следил за диском (остальные при этом наблюдали фотографию лаборатории).
Почти месяц цвет диска не менялся. Но сегодня ночью, наконец,
портал открылся. К счастью, это произошло в ночь на воскресенье, когда в институте дежурил только один
солдат. Петр был в опустевшем институте уже через несколько минут.]];
	};
}

room {
	nam = 'r2';
	title = 'Перед институтом';
	decor = [[Петр находится перед родным для него {#нии|НИИ}. Сейчас около 3 часов ночи.]];
	way = { path { 'К проходной', 'проходная' } };
}: with
{
	obj {
		nam = '#нии';
		act = [[Только в одном окне виден свет. Это лаборатория Петра. Там находится портал.]];
	};
}

obj {
	nam = 'пропуск';
	inv = function(s)
		p [[Магнитная карточка.]]
	end;
	use = function(s, w)
		if w^'#сторож' then
			if w.sleep then
				p [[Стоит ли будить сторожа?]]
			elseif here().pass then
				p [[-- Михалыч, у меня и пропуск есть! -- радостно сказал Петр. Михалыч не ответил.]];
			else
				p [[-- Михалыч, у меня пропуск есть!^-- Приказ генерала, никого не пускать ночью! -- буркнул Михалыч.]]
			end
			return
		elseif w^'#турникет' then
			if here().pass then
				p [[Путь свободен!]]
			else
				p [[Петр поднес пропуск к считывателю как это делал несчетное число раз. Но зеленая лампочка не загорелась.]]
			end
			return
		end
		p [[Пропуск тут не поможет.]]
	end;
}

room {
	nam = 'проходная';
	title = 'Проходная';
	pass = false;
	decor = [[Внутри проходной темно и тихо.]];
	enter = function(s, f)
		if f^'r2' then
			_'#сторож'.sleep = true
		end
	end;
	onexit = function(s, t)
		if s.pass then
			return
		end
		if t^'у кабинета' then
			if not _'#сторож'.sleep then
				return [[Михалыч неодобрительно смотрит на Петра.]], false
			end
			_'#сторож'.sleep = false
			p [[Петр попытался пролезть под турникетом, но больно стукнулся макушкой и непроизвольно высказал неудовольствие происходящим.]]
			p [[Высказывание разбудило сторожа.]]
			walkin 'сторож'
			return false
		end
	end;
	way = { path { 'На улицу', 'r2' }, path { 'В институт', 'у кабинета' } };
}: with
{
	obj {
		nam = '#турникет';
		act = function()
			if here().pass then
				p [[На турникете горит зеленая лампочка.]]
			else
				p [[В принципе, под турникетом можно пролезть.]]
			end
		end;
	};
	obj {
		nam = '#сторож';
		dsc = function(s)
			p [[В кабинке, перед {#турникет|турникетом},]]
			if s.sleep then
				p [[дремлет {сторож}.]]
			else
				p [[сидит {Михалыч}.]]
			end
		end;
		sleep = true;
		know = false;
		act = function(s)
			if here().pass then
				if s.sleep then
					s.sleep = false
					pn [[-- Михалыч, так можно мне пройти? -- крикнул Петр.]]
					p [[-- А, что? Да, конечно, будьте любезны, Петр Геннадьевич.]]
				else
					p [[-- Проходите, Петр Геннадьевич.]]
				end
				return
			end
			if s.sleep then
				s.sleep = false;
				pn [[-- Михалыч! Зачем-то громко крикнул Петр.]]
				pn [[-- Что, кто здесь?]];
				walkin 'сторож'
			else
				walkin 'сторож'
			end
		end;
	}
}
dlg {
	nam = 'сторож';
	title = 'Разговор с Михалычем';
	enter = function(s)
		if visited(s) then
			s:reset('#был')
		end
	end;
	dsc = [[Сторож Михалыч смотрит на Петра. В его сонных глазах читается вопрос.]];
	phr = {
		{ "Это я, Михалыч!", "-- Здравствуйте, Петр Геннадьевич!", next = '#2', },
		{ '#2', "Спи спокойно, Михалыч.", "-- Спасибо, Петр Геннадьевич, но я на службе!",
		  { 'Михалыч, мне нужно в свою лабораторию!',
		    '-- Мне очень жаль, Петр Геннадьевич, но приказ генерала -- никого ночью не пускать!',
		    { 'Ну пусти, ну мне очень надо!', '-- Не имею возможности нарушить указ генерала, Петр Геннадьевич!' },
		    { 'Михалыч, если ты меня не пустишь, я расскажу Сан Санычу, что ты спал на службе...',
		      function ()
			      seen('#сторож', 'проходная').know = true
			      p '-- Эх, и не совестно вам, Петр Геннадьевич? Я никогда не сплю на рабочем месте!'
			      walkout()
		      end,
		    },
		  },
		  { 'Как дела, Михалыч?', '-- Как сажа бела, Петр Генадьевич.' }
		},
		{ false, '#был',
		  { "Это же я, Михалыч! Пусти, а?", "-- Не имею возможности, Петр Геннадьевич -- приказ генерала." }
		},
		{ false, '#пусти',
		  { 'Вот, Михалыч, посмотри фотку.', 'Сторож поправил очки и посмотрел на экран навороченного смартфона Петра.^ -- Ох, Петр Геннадьевич, да как же это возможно!',
		    {'Михалыч, мне очень нужно в лабораторию.',
		     [[Я сотру эти фотки, а ты не будешь говорить генералу о том, что я пришел поработать ночью, хорошо?^
-- Хорошо, Петр Генадьевич -- в голосе сторожа чувствуется обида -- но вы уж наверняка сотрите!]],
		     { 'Конечно, сотру, Михалыч!', function(s) p [[-- Проходите, Петр Геннадьевич!]]; _'проходная'.pass = true; walkout() end };
		    },
		    { 'Я выложу фотки в инстаграмм!', '-- Ин сто грамм?' },
		  };
		},
	}
}
obj {
	nam = 'мобильник';
	photos = false;
	tak = function(s)
		if not here().light then
			return _'дверь1':act()
		end
		p [[Петр забрал мобильник.]];
	end;
	dsc = [[На полу около {дверь1|двери} лежит включенный {мобильник}.]];
	inv = function(s)
		if s.photos then
			p [[В галерее есть новые фотки спящего Михалыча.]]
		else
			p [[Навороченный китайский смартфон. Работает почти стабильно.]]
		end
	end;
	use = function(s, w)
		if w^'#сторож' then
			if not w.sleep then
				if here().pass then
					p [[Не стоит лишний раз расстраивать Михалыча.]]
					return
				end
				if s.photos then
					walkin 'сторож'
					_'сторож':reset '#пусти'
					return
				end
				p [[-- Михалыч, можно тебя сфоткать?^-- Это еще зачем, Петр Геннадьевич? -- насторожился Михалыч.]]
				return
			end
			if not w.know then
				p [[Петр решил не звонить Михалычу.]]
				return
			end
			if s.photos then
				p [[Подумав, Петр стер фотки Михалыча и сделал несколько новых, гораздо лучших!]]
			else
				p [[Подумав, Петр сделал несколько снимков спящего Михалыча.]]
				p [[Залить что-ли в инстаграмм? -- Подумал Петр -- Но тогда у Михалыча могут быть проблемы...]];
				s.photos = true
			end
			return
		elseif w^'дверь1' then
			if seen 'щиток' and actions(w) > 0 then
				p [[Петр включил мобильник и положил его около двери в хозяйственное помещение.]]
				drop(s)
				return
			end
		elseif w^'#тьма' then
			p [[Петр посветил мобильником. Недалеко он заметил дверь.]]
			return
		end
		p [[Мобильник тут не поможет.]]
	end;
}

room {
	nam = 'у кабинета';
	light = true;
	title = '5-й этаж';
	first = false;
	life = function(s)
		if not s.first then
			s.first = true
			return
		end
		lifeoff(s)
		s.first = false
		s.light = true
		enable '#свет'
		enable 'щиток'
		disable '#тьма'
		enable 'дверь1'
		p [[Солдат приближался. Он шел к щитку. Все, что оставалось Петру это спуститься на 4-й этаж и подождать,
пока солдат не включит свет и вернется на свой пост. Петр снова поднялся на пятый этаж.]];
		return true
	end;
	enter = function(s, f)
		if f^'проходная' then
			p [[В институте было темно, но Петр боялся включать свет. Он быстро и бесшумно (если
не считать проклятого ведра между вторым и третьим этажами) поднялся на пятый этаж, где располагалась
его лаборатория...]]
		end
	end;
	decor = function(s)
		if s.light then
			p [[Петр находится в коридоре пятого этажа. Прямо за {#угол|углом} находится лаборатория.
В коридоре горит {#свет|свет}. Рядом в стене есть {дверь1|дверь}.]];
		else
			p [[Петр находится в абсолютной {#тьма|темноте}. Где-то за {#угол|углом} стены находится лаборатория.]];
		end
	end;
--	way = { path { 'В лабораторию', 'лаборатория' } };
}
:with
{
	obj {
		nam = '#тьма';
		act = [[Хоть глаз выколи!]];
	}:disable();
	obj {
		nam = 'дверь1';
		act = function(s)
			if here().light then
				p [[Петр осторожно приоткрыл дверь. Это было хозяйственное помещение. Кроме ведра с грязной тряпкой -- ничего интересного.]];
			else
				take 'мобильник'
				lifeoff(here())
				walk 'lab-scene'
				return
			end
		end;
	};
	obj {
		nam = '#свет';
		act = function(s)
			p [[Тусклый свет флуоресцентных ламп очень неприятен Петру.]]
			if actions '#угол' > 0 then
				p [[Петру зачем-то приходит мысль,
что на каждом этаже института есть щиток.]];
				enable 'щиток'
			end
		end;
	};
	obj {
		nam = '#угол';
		act = function(s)
			if here().light then
				p [[Петр осторожно выглянул из-за угла. У двери лаборатории стоит солдат. Нужно что-то придумать.]];
			else
				p [[Петр подошел к углу и прислушался. Он услышал звук приближающихся шагов!]];
			end
		end;
	};
	obj {
		nam = 'щиток';
		dsc = [[Возле лифта на этаже находится электрический {щиток}.]];
		act = function(s)
			here().light = false
			disable '#свет'
			pn [[Петр тихо подошел к щитку, открыл его и выключил автомат. Коридор погрузился во тьму.]]
			p [[-- Опять автоматы не выдержали, гражданские ... (дальше неразборчиво) -- услышал Петр недовольный голос солдата из-за угла.]];
			disable (s)
			enable '#тьма'
			if not seen 'мобильник' then
				disable 'дверь1'
			end
			lifeon(here())
		end;
	}:disable();
}
scene {
	nam = 'lab-scene';
	title = '';
	next = 'Лаборатория';
	decor = {
		[[Благодаря своей находчивости, Петр точно знал где находится хозяйственное помещение.
Он бесшумно забрался в каморку, предварительно подняв мобильник с пола.]];
		[[Затем он подождал, пока солдат не пройдет мимо, по направлению к щитку. И так же бесшумно
вылез из каморки и завернул за угол. Перед ним была дверь лаборатории. В этот момент загорелся свет.]],
		[[Время было дорого! Петр прислонил пропуск к двери... Половина секунды тянулась вечность,
но вот -- Петр уже внутри лаборатории!]];
	}
}

game.onact = function(s, w)
	if here()^'Лаборатория' then
		if _'#холодильник'.portal then
			if not (w ^'#холодильник') then
				p [[Петра сейчас интересует только портал!]]
				return false
			end
		end
		return
	end
	if here().onact then
		return std.call(here(), 'onact', w)
	end
	return
end
room {
	nam = 'Лаборатория';
	portal = false;
	decor = [[Петр внутри лаборатории. Глаза уже успели привыкнуть к темноте и Петр различает
{#диск|артефакт}, который лежит на одном из {#стол|столов}. В {#окна|окна} лаборатории тускло льется звездный свет.
]];
}: with {
	obj {
		nam = '#диск';
		act = function(s)
			if s:actions() == 0 then
				p [[Странно, но Петр не обнаружил проволочной рамки у артефакта.]]
			end
			p [[Артефакт в форме диска медленно пульсирует. В темноте это хорошо заметно. Где-то рядом должен быть
портал. Надо его найти!]]
			here().portal = true
		end;
	};
	obj {
		nam = '#стол';
		act = function()
			if here().portal then
				p [[Петр поискал портал под столами, но не обнаружил его.]]
			else
				p [[В лаборатории несколько больших столов.]]
				return
			end
			if not seen 'кот' then
				p [[Под столом Петр заметил два зеленых огонька.]]
				enable 'кот'
			end
		end;
	};
	obj {
		nam = '#окна';
		act = function()
			if here().portal then
				p [[В прошлый раз портал открылся в одном из окон. Но сейчас его здесь нет.]]
			else
				p [[За окнами ночь.]]
			end
		end;
	};
	obj {
		nam = '#холодильник';
		seen = false;
		portal = false;
		dsc = function(s)
			if s.seen then
				p [[В углу стоит {холодильник}.]]
			else
				return false
			end
		end;
		act = function(s)
			if s.portal then
				walk 'В портал'
				return
			end
			if s.seen then
				s.portal = true
				p [[Петр подошел к огромному холодильнику. Дверь холодильника была открыта. Это показалось Петру странным,
так как Гегель обычно закрывал за собой дверь. Но еще более странным было то, что за дверью холодильника ничего не было! Только
серебристая рябь пространства, едва различимая в темноте. Вот он, портал! -- понял Петр.]];
				return
			end
			if here().portal then
				s.seen = true;
				p [[Петр решил осмотреть холодильник, о существовании которого он совсем забыл. Холодильник находился в дальнем углу лаборатории.]]
			else
				p [[Петру не хочется есть.]]
			end
		end;
	};
	obj {
		nam = 'кот';
		know = false;
		dsc = function(s)
			if s.know then
				p [[Под столом Петр видит {Гегеля}.]];
			else
				p [[Под столом Петр видит два зеленых {огонька}.]];
			end
		end;
		act = function(s)
			if _'#холодильник'.seen then
				p [[Гегель выглядит недовольным.]]
				return
			end
			if s:actions() <= 2 then
				if s:actions() == 0 then
					p [[Может не надо?]]
				elseif s:actions() == 1 then
					p [[А вдруг это опасно?]]
				elseif s:actions() == 2 then
					p [[Может быть, стоит сначала сохраниться?]]
				end
				return
			end
			s.know = true
			enable '#рамка'
			p [[Петр осторожно подошел к столу и опустился на корточки. Уффф! Это же Гегель! Лабораторный кот! Правда, обычно он ошивается около {#холодильник|холодильника}.
Он может свободно входить и выходить из лаборатории через специальную дверцу в двери.
Рядом с котом Петр заметил смятую проволочную рамку.]];
		end;
	}:disable();
	obj {
		nam = '#рамка';
		dsc = [[Возле Гегеля валяется проволочная {рамка}.]];
		act = [[Если бы не Гегегль, портал открылся бы в проволочной рамке, которая специально
была установлена здесь. Похоже, коту рамка не понравилась. Нужно будет запретить ему вход в лабораторию.]]
	}:disable();
}
cat = player { nam = 'Гегель', room = 'дерево' }

scene {
	nam = 'В портал';
	title = '';
	next = 'дерево';
	decor = {
		[[Петр исчез в холодильнике...]];
		[[... Гегель был зол. Сначала пропала вкусная еда из холодильника. Потом Петр не покормил Гегеля, и вместо этого пропал в холодильнике.
А потом настал длинный и скучный день, когда в лаборатории никого нет, и нет еды в холодильнике.]],
		[[Когда стало совсем светло, Гегель взобрался на подоконник и начал смотреть в окно. Но никто
не приходил. Время тянулось медленно. За окном пошел дождь. Гегель просидел на подоконнике до конца дня.]];
		[[Ночь. Петр все не возвращался из холодильника. Кажется кто-то идет! Нет, это шум дождя. Бедный Гегель не доживет до следующего дня.
Бедный Гегель умрет с голоду. Нужно вернуть Петра, чтобы он покормил Гегеля. Но холодильник страшный!]];
		fmt.em [[Гегель будет терпеть до утра!]];
		fmt.em [[Гегель будет терпеть до утра!!]];
		fmt.em [[Гегель будет терпеть до утра!!!]];
		fmt.em [[Гегель идет за Петром в холодильник!!!!]];
	};
	exit = function(s)
		change_pl(cat)
	end;
}

room {
	nam = 'дерево';
	onact = function(s)
		return _'Озеро':onact()
	end;
	title = [[У дерева]];
	onexit = function(s, w)
		if w ^'Лаборатория' then
			if seen 'чайка' then
				disable '#наверх'
				walk 'Повтор'
				lifeoff 'чайка'
				remove 'чайка'
				return false
			end
			p [[Гегелю надо найти человека.]]
			return false
		end
	end;
	enter = function(s, f)
		if f ^ 'В портал' then
			p [[Звуки. Запахи. Свет. Гегель был сбит с толку, ведь только что была ночь, а теперь снова вечер. Странный холодильник.]];
		end;
	end;
	decor = [[Гегель находится на холме. Рядом стоит старый {#дуб|дуб}. Холм и луг под холмом покрыт зеленой {#трава|травой}. Еще дальше
Гегель видит огромное плоское {#озеро|озеро}, которое искрится в лучах заходящего {#солнце|солнца}. Прохладный {#ветер|ветерок} обдувает Гегеля.]];
	way = { path {'#в дупло', 'В дупло', 'Лаборатория'}:disable(),
		path { '#к озеру', 'К озеру', 'Озеро'}:disable(),
		path { '#наверх', 'Наверх', 'На дереве'}:disable(),
		path { 'В лес', 'В лес', 'Лес'}:disable()};
}:with {
	obj {
		nam = '#дуб';
		tree = false;
		act = function(s)
			if not seen '#портал' then
				enable '#портал'
				enable '#в дупло'
			end
			if seen 'чайка' then
				s.tree = true
			end
			if s.tree then
				enable '#наверх'
				p [[Гегель подумал, что смог бы забраться на дерево.]]
			else
				p [[Гегель видит в дубе огромное дупло. Через это дупло Гегель попал сюда.]]
			end
		end;
	};
	obj {
		nam = '#озеро';
		act = function(s)
			p [[Со стороны озера доносится запах рыбы.]];
			enable '#к озеру'
		end;
	};
	obj {
		nam = '#трава';
		act = [[Травинки едва заметно шевелятся. Гегель слышит как они шелестят.]];
	};
	obj {
		nam = '#солнце';
		act = [[Красное солнце скоро зайдет за горизонт.]];
	};
	obj {
		nam = '#ветер';
		act = function(s)
			p [[Гегель чувствует разные запахи. Но запаха человека -- нет.]]
		end;
	};
	obj {
		nam = '#портал';
		dsc = [[В дубе зияет огромное {дупло}.]];
		act = function()
			p [[Гегелю не нравится это дупло.]];
		end;
	}:disable();
}

room {
	nam = 'Озеро';
	onact = function(s)
		if seen 'чайка' and _'чайка'.step >= 2 then
			p [[Гегелю нужно скрыться от чайки!]]
			return false
		end
	end;
	enter = function(s)
		_'чайка'.step = 0
		lifeon 'чайка'
	end;
	decor = [[Гегель слышит, как волны большого {#озеро|озера} накатываются на берег.
Над озером кружат {#чайки|чайки}.]];
	way = { path { 'К дубу', 'дерево'} };
}: with {
	obj {
		nam = '#озеро';
		act = [[Пахнет рыбой и водорослями, но рыба в воде. Человека здесь тоже нет.]];
	};
	obj {
		nam = '#чайки';
		act = function()
			p [[Их пронзительный крик разносится по озеру.]]
		end;
	};
}
obj {
	nam = 'чайка';
	step = 0;
	act = [[Гегель понимает, что это птица, но чайка кажется огромной. И еще она пронзительно кричит!]];
	dsc = function(s)
		if s.step < 2 then
			p [[Гегель видит, как одна крупная {чайка} летит к нему.]]
		else
			p [[{Чайка} совсем рядом! Ее пронзительный крик пугает Гегеля. Она собирается атаковать!]]
		end
	end;
	life = function(s)
		if player_moved() then
			s.step = 0
		end
		place(s)
		s.step = s.step + 1
	end;
}

room {
	nam = 'На дереве';
	enter = function()
		if live 'чайка' then
			lifeoff 'чайка'
			remove 'чайка';
			p [[Гегель кое-как забрался на дуб и затаился в старых узловатых ветвях.
Чайка еще некоторое время покружила вокруг дерева, пугая кота, но потом все-таки улетела обратно в сторону озера.]]
		else
			p [[Гегель кое-как забрался на дуб.]]
		end
	end;
	decor = [[Гегель находится на дереве. Он прячется между толстыми узловатыми {#ветки|ветками}.]];
	obj = {
		obj {
			nam = '#ветки';
			act = [[Пахнет дубом.]];
		};
	};
	way = { path { 'Вниз', 'дерево' }, path { 'Вверх', 'высоко'} };
}

room {
	nam = 'высоко';
	title = 'Еще выше';
	enter = [[Гегель попробовал взобраться повыше. И ему это удалось!]];
	decor = [[Гегель забрался высоко. Усы Гегеля дрожат по дуновением ветра.
Отсюда открывается прекрасный {#вид|вид}.]];
	way = { path { 'На землю', 'дерево' } };
}: with {
	obj {
		nam = '#вид';
		act = function()
			enable '#корабль';
			p [[Гегель видит лес. Еще Гегель видит нечто странное.]];
		end
	};
	obj {
		nam = '#корабль';
		dsc = [[Гегель видит что-то {странное} в лесу.]];
		act = function()
			p [[Гегель видит, что часть деревьев повалены и среди них
в землю врыта какая-то громадина. Она выглядит так, как будто ее сделали люди.
Гегель думает, что там может быть человек.]];
			enable 'В лес'
		end;
	}:disable();
}
scene {
	nam = 'Повтор';
	tilte = 'Бегство';
	next = 'дерево';
	decor = {
		[[Гегель бросился в дупло. Через мгновенье он вылетел из холодильника в лабораторию.
Здесь все было по-прежнему. По стеклу текли капли дождя, а холодильник был пуст...]];
		[[Гегель не мог успокоиться, он ходил из стороны в сторону по подоконнику глядя на улицу.]];
		[[Наконец, он не выдержал, и снова бросился к холодильнику...]];
	};
}

room {
	nam = 'Лес';
	enter = function(s, f)
		if f ^ 'дерево' then
			p [[Гегель устремился в сторону леса.]]
		end
	end;
	decor = [[Гегель видит поваленные {#деревья|деревья}. Странная {#громада|громада} возвышается
над котом.]];
	way = { path { 'Внутрь', 'Внутри' }, path { 'На холм', 'дерево' } };
}:with {
	obj {
		nam = '#деревья';
		act = [[Их повалила эта громада? Может быть, она упала на них?]];
	};
	obj {
		nam = '#громада';
		act = function()
			p [[Громада пугает Гегеля. Но ему кажется, что где еще быть человеку, как не внутри?]];
			if disabled 'Внутри' then
				p [[Гегель видит проход внутрь.]]
				enable 'Внутри'
			end
		end;
	};
}

room {
	nam = 'Внутри';
	way = { path { 'Назад', 'Лес' } };
}:disable();

function init()
	take 'пропуск'
	take 'мобильник';
end
