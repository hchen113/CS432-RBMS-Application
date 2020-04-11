import java.sql.*;
import oracle.jdbc.*;
import java.math.*;
import java.io.*;
import java.awt.*;
import oracle.jdbc.pool.OracleDataSource;


public class rbms_application {

    public static void main (String args []) throws SQLException{

        try{

            OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
            ds.setURL("jdbc:oracle:thin:@castor.cc.binghamton.edu:1521:ACAD111");
            Connection conn = ds.getConnection("hchen113", "qazwsxedc");
            Statement stmt = null;
            ResultSet rset = null;

            System.out.print("Connection Established With Oracle Server. \n\n\n");

            stmt = conn.createStatement();

            BufferedReader  readKeyBoard; 
            int             selection = 9;
            boolean         exit = false;
            readKeyBoard = new BufferedReader(new InputStreamReader(System.in));
            while (exit == false){
                System.out.print("Retail Business Magagement System: Main Menu.\n\nPlease choose an option below:\n1. Add a purchase to the database.\n2. Add new product to inventory.\n3. Single Product Monthly Sales Report.\n4. View Database.\n\n\n0. Exit RBMS.\n");
                selection = Integer.parseInt(readKeyBoard.readLine()) ;
                if (selection == 1){
                    System.out.print("You have selected 'Add Purchase'. \n");
                    
                    try {
                        CallableStatement cstmt = conn.prepareCall("begin rbms.add_purchase(?,?,?,?,?); end;");

                        String  eid;
                        String  pid;
                        String  cid;
                        int     qty;


                        System.out.print("Please enter employee ID as 'e##'.\n");
                        eid = readKeyBoard.readLine();

                        System.out.print("Please enter product ID as 'p###'.\n");
                        pid = readKeyBoard.readLine();

                        System.out.print("Please enter customer ID as 'c###'.\n");
                        cid = readKeyBoard.readLine();

                        System.out.print("Please enter the qty of product being purchased as ####.\n");
                        qty = Integer.parseInt(readKeyBoard.readLine());

                        cstmt.setString(1, eid);
                        cstmt.setString(2, pid);
                        cstmt.setString(3, cid);
                        cstmt.setInt(4, qty);
                        
                        cstmt.registerOutParameter(5, Types.VARCHAR);
                        cstmt.execute();

                        String output = cstmt.getString(5);
                        String new_output = output.replaceAll(" X ", "\n");
                        System.out.print(new_output + "\n\n");

                        System.out.print("Transaction complete. Returning to main menu.\n\n\n");
                    } catch (SQLException ex) {
                        System.out.print("Error" + ex + " \nReturning to main menu. \n\n");
                    }
                    
                }else if(selection == 2){
                    System.out.print("You have selected 'Add Product'.\n");
                    try {
                        CallableStatement cstmt = conn.prepareCall("begin rbms.add_product(?,?,?,?,?,?,?); end;");

                        String  pid;
                        String  pname;
                        int     amt;
                        int     threshold;
                        float   price;
                        float   discount;



                        System.out.print("Please enter product ID as 'p###'.\n");
                        pid = readKeyBoard.readLine();

                        System.out.print("Please enter product's name 'xxxxxx'. (Maximum 15 characters) \n");
                        pname = readKeyBoard.readLine();

                        System.out.print("Please enter product quantity as a number. (Maximum 5 digits) \n");
                        amt = Integer.parseInt(readKeyBoard.readLine());

                        System.out.print("Please enter the quantity threshold before automatic resupply. (Maximum 4 digits) \n");
                        threshold = Integer.parseInt(readKeyBoard.readLine());

                        System.out.print("Please enter the products MSRP as ####.##. (Maximum 6 digits) \n");
                        price = Float.parseFloat(readKeyBoard.readLine());

                        System.out.print("Please enter the products discount rate as 0.##. (Maximum 3 digits and must be between 0 and 0.8) \n");
                        discount = Float.parseFloat(readKeyBoard.readLine());

                        cstmt.setString(1, pid);
                        cstmt.setString(2, pname);
                        cstmt.setInt(3, amt);
                        cstmt.setInt(4, threshold);
                        cstmt.setFloat(5, price);
                        cstmt.setFloat(6, discount);
                        cstmt.registerOutParameter(7, Types.VARCHAR);
                        
                        cstmt.execute();

                        String output = cstmt.getString(7);
                        System.out.print(output);

                        

                        System.out.print(" Adding product complete. Returning to main menu.\n\n\n");
                    } catch (SQLException ex) {
                        System.out.print("Error" + ex + " \nReturning to main menu. \n\n");
                    }

                }else if (selection == 3){
                    System.out.print("You have selected 'Single Product Monthly Sales Report'.\n");
                    try {
                        CallableStatement cstmt = conn.prepareCall("begin rbms.report_monthly_sale(?,?); end;");

                        String  pid;
                        
                        System.out.print("Please enter the product ID in 'p####'.\n");
                        pid = readKeyBoard.readLine();

                        cstmt.setString(1, pid);
                        cstmt.registerOutParameter(2, Types.VARCHAR);

                        cstmt.execute();

                        String output = cstmt.getString(2);
                        String list_output = output.replaceAll("X ", "\n");
                        System.out.print(list_output + "\n\n");



                    } catch (Exception ex) {
                        System.out.print("Error" + ex + " \nReturning to main menu. \n\n");
                    }

                }else if(selection == 4){
                    boolean exit_show = false;
                    while(exit_show == false){
                        System.out.print("You have selected 'View Database'.\n\nPlease select one of the following tables to view:\n");
                        System.out.print("1. Customers\n2. Employees\n3. Products\n4. Purchases\n5. Suppliers\n6. Supply\n7. Log\n\n\n All other options will result in returning to the main menu.\n");
                        int choice = Integer.parseInt(readKeyBoard.readLine());

                        if (choice == 1){
                            CallableStatement cstmt = conn.prepareCall("begin rbms.show_customers(?); end;");
                            cstmt.registerOutParameter(1, Types.VARCHAR);
                            cstmt.execute();
                            String output = cstmt.getString(1);
                            String list_output = output.replaceAll(" X", "\n");
                            System.out.print(list_output + "\n\n");

                        }else if (choice == 2){
                            CallableStatement cstmt = conn.prepareCall("begin rbms.show_employees(?); end;");
                            cstmt.registerOutParameter(1, Types.VARCHAR);
                            cstmt.execute();
                            String output = cstmt.getString(1);
                            String list_output = output.replaceAll(" X", "\n");
                            System.out.print(list_output + "\n\n");

                        }else if (choice == 3){
                            CallableStatement cstmt = conn.prepareCall("begin rbms.show_products(?); end;");
                            cstmt.registerOutParameter(1, Types.VARCHAR);
                            cstmt.execute();
                            String output = cstmt.getString(1);
                            String list_output = output.replaceAll(" X", "\n");
                            System.out.print(list_output + "\n\n");

                        }else if (choice == 4){
                            CallableStatement cstmt = conn.prepareCall("begin rbms.show_purchases(?); end;");
                            cstmt.registerOutParameter(1, Types.VARCHAR);
                            cstmt.execute();
                            String output = cstmt.getString(1);
                            String list_output = output.replaceAll(" X", "\n");
                            System.out.print(list_output + "\n\n");

                        }else if (choice == 5){
                            CallableStatement cstmt = conn.prepareCall("begin rbms.show_suppliers(?); end;");
                            cstmt.registerOutParameter(1, Types.VARCHAR);
                            cstmt.execute();
                            String output = cstmt.getString(1);
                            String list_output = output.replaceAll(" X", "\n");
                            System.out.print(list_output + "\n\n");

                        }else if (choice == 6){
                            CallableStatement cstmt = conn.prepareCall("begin rbms.show_supply(?); end;");
                            cstmt.registerOutParameter(1, Types.VARCHAR);
                            cstmt.execute();
                            String output = cstmt.getString(1);
                            String list_output = output.replaceAll(" X", "\n");
                            System.out.print(list_output + "\n\n");

                        }else if (choice == 7){
                            CallableStatement cstmt = conn.prepareCall("begin rbms.show_log(?); end;");
                            cstmt.registerOutParameter(1, Types.VARCHAR);
                            cstmt.execute();
                            String output = cstmt.getString(1);
                            String list_output = output.replaceAll(" X", "\n");
                            System.out.print(list_output + "\n\n");

                        }else{
                            exit_show = true;
                        }

                    }

                    System.out.print("Returning to main menu.\n\n");
                    
                
                }else if(selection == 0){
                    System.out.print("You have selected 'Exit'.\n");
                    exit = true;
                }else{
                    System.out.print("\n");
                    System.out.print("Input Error. Please select either option 1, 2 or exit with option 0.\n");
                }
            }
            System.out.print("Successfully exited RBMS. Closing Application.\n");
            stmt.close();
            conn.close();
        }

        catch (SQLException ex) { 
            System.out.print("SQL Error" + ex);
        }
        catch (Exception e) {
            System.out.print("Program Error" + e);
        }
    }

    public static void resupply(String pid, int amt) {
        System.out.print("\nPRODUCT ID " + pid + " IS BELOW QOH THRESHOLD. NEW SUPPLY IS REQUIRED.\n");
        System.out.print("PRODUCT ID " + pid + " - SUPPLY ORDERED.\n");
        System.out.print("PRODUCT ID " + pid + " NOW HAS " + amt + " AVALIABLE.\n\n");
    }
    
}