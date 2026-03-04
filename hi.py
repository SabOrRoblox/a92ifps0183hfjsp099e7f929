import hashlib, sys
# кол-во попыток, можешь мегять
attempts=3
print("Всього 2 етапи, перший - найбільше з трьох, якщо в ньому найбільше А або B - перехід на наступний етап")
def password():
    # global - это как права, чтобы изменять переменную, внутри этого блока def, и сохранять изменения глобально для всего
    global attempts
    pas="33068104e2ac89567e79b95aaafb4f2efecae3960b76246de777236f7a206550"
    # цикл while хавает функцию, если остались попытки, то есть больше нуля, дальше если меньше, if чуть дальше вырубает работу
    while attempts>0:    
        OO=input("Введи пароль: ")
        O1=hashlib.sha3_256(OO.encode()). hexdigest()
        if O1==pas:
              return True
              print("пароль правильний\n")
        else:
            attempts -=1
            print("Неправильний пароль, залишилось спроб: ", attempts)
            
    if attempts==0:
        print("спробуй наступного разу")
        sys.exit(1)

def Calc():
    print("Другий етап: калькулятор, основні дії, на двух числах")
    _1=int(input("перше число: ")) 
    _2=int(input("друге число: "))
    dia=input("що ти хочеш з ними зробити? (дія): ")
    
    if dia in ("+", "додати"):
        print(_1+_2)
    elif dia in ("-", "відняти"):
        print(_1-_2)
    elif dia in ("*", "×", "помножити"):
        print(_1*_2)
    elif dia in (":", "/", "поділити"):
        print(_1/_2)
    elif dia=="**":
        print(_1**_2)

def informatica():
    print("Перший етап: найбільше число з трьох введених")
    a=int(input("а = ? "))
    x = 123
    # -------------------------------- 
    if a==x:
        print("a співпало с числом, далі другий етап")
        Calc()
    else:
        pass
    # --------------------------------
    b=int(input("b = ? "))
    c=int(input("c = ? "))
    
    m = max(a, b, c)
    print("найбільше: ", m)        
        
    if m in (a,b):
        Calc()
    else:
        print("хз")

def main():
    # если функция пассворд успешна и сделает return True - продолжать работу
    if password():
        informatica()
    else:
        print("неправильний пароль")

main()
